#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

//#include <Tie::LevelDB>

#ifdef __cplusplus
}
#endif

#include<iostream>
#include<leveldb/db.h>
#include<leveldb/slice.h>
#include<leveldb/iterator.h>
#include<leveldb/write_batch.h>

void status_assert(leveldb::Status s) {
	if(!s.ok()) std::cerr << s.ToString() << std::endl;
}

class Iterator {
protected:
	leveldb::Iterator *it;
public:
	Iterator() {
		it = NULL; // die!
	}
	Iterator(leveldb::Iterator *it) : it(it) { }
	~Iterator() { delete it; it = NULL; }
	void SeekToFirst() { it->SeekToFirst(); }
	void SeekToLast()  { it->SeekToLast(); }
	void Seek(const char* c_target) { // fix: allow \0 in target
		leveldb::Slice* target = 
			new leveldb::Slice(c_target,strlen(c_target));
		it->Seek(*target);
	}
	void Next()  { it->Next(); }
	void Prev()  { it->Prev(); }
	bool Valid() { return it->Valid(); }
	const char* key() { 
		const char* k = it->key().ToString().c_str();
		status_assert(it->status());
		return k;
	}
	const char* value() { 
		const char* v = it->value().ToString().c_str();
		status_assert(it->status());
		return v;
	}
};

class WriteBatch {
protected:
	leveldb::WriteBatch *batch;
public:
	leveldb::WriteBatch* get_batch() { return batch; }

	WriteBatch() {
		batch = new leveldb::WriteBatch();
	}
	~WriteBatch() {
		delete batch;
	}
	void Put(const char* key,const char * cvalue) {
		if(cvalue) {
			std::string* value = new std::string(cvalue);
			batch->Put(key, *value);
		} else Delete(key); // LevelDB limitation..
	}
	void Delete(const char * key) {
		batch->Delete(key);
	}
};

class DB {
protected:
	leveldb::DB *db;
public:
	DB() : db(NULL) { }
	DB(const char* name,HV* hv_options=NULL ) : db(NULL) { 
		Open(name,hv_options);
	}
	~DB() {
		if(db) { delete db; db = NULL; }
	}
	void Open(const char* name,HV* hv_options=NULL) { 
		leveldb::Options options; // todo: construct
		options.create_if_missing = true;
		// options.error_if_exists = true;
		if(db) delete db;
		status_assert(leveldb::DB::Open(options, name, &db));
	}
	void Put(const char* key,const char* cvalue=NULL,
			 HV* hv_write_options=NULL) {
		leveldb::WriteOptions write_options;
		if(cvalue) {
			std::string* value = new std::string(cvalue);
			status_assert(db->Put(write_options, key, *value));
		} else {
			status_assert(db->Delete(leveldb::WriteOptions(), key));
		}
	}
	const char* Get(const char* key) {
		std::string value;
		leveldb::Status s = db->Get(leveldb::ReadOptions(), key, &value);
		if(s.IsNotFound()) return NULL;
		status_assert(s);
		return value.c_str();
	}
	void Delete(const char* key) {
		status_assert(db->Delete(leveldb::WriteOptions(), key));
	}
	void Write(WriteBatch* batch,HV* hv_write_options=NULL) {
		leveldb::WriteOptions write_options; // todo: construct
		status_assert(db->Write(write_options,batch->get_batch()));
	}
	Iterator* NewIterator(HV* hv_read_options=NULL) {
		leveldb::ReadOptions read_options; // todo: construct
		return new Iterator(db->NewIterator(read_options));
	}
};

class LevelDB : DB {
	Iterator* it;
public:
	LevelDB() : it(NULL) {}
	LevelDB(const char* name,HV* hv_options=NULL) {
		db = NULL; it = NULL;
		Open(name,hv_options);	
	}
	~LevelDB() { 
		if(it) { delete it; it = NULL; }
		if(db) { delete db; db = NULL; }
	}
	const char* FETCH(const char* key) {
		return Get(key);
	}
	void STORE(const char* key,const char* value=NULL) {
		Put(key,value);
	}
	void DELETE(const char* key) {
		Delete(key);
	}
	void CLEAR() {
    std::cerr << "CLEAR()" << std::endl;
    WriteBatch batch;
		Iterator* it = NewIterator();
		for(it->SeekToFirst();it->Valid();it->Next()) batch.Delete(it->key());
		delete it;
    Write(&batch);
	}
	bool EXISTS(const char* key) {
		Iterator* find = NewIterator();
		find->Seek(key);
		bool valid = find->Valid();
		delete(find);
		return valid;
	}
	const char* FIRSTKEY() {
		if(it) delete it;
		it = NewIterator();
		it->SeekToFirst();
		return it->Valid() ? it->key() : NULL;
	}
	const char* NEXTKEY(const char* lastkey) {
		if(!it) return NULL;
		it->Next();
		return it->Valid() ? it->key() : NULL;
	}
	int SCALAR() {
		int count = 0;
		Iterator* it = NewIterator();
		for(it->SeekToFirst();it->Valid();it->Next()) count++;
		delete it;
		return count;
	}
};

MODULE = Tie::LevelDB		PACKAGE = Tie::LevelDB::DB

DB*
DB::new(char* name=NULL,HV* hv_options=Nullhv)

void
DB::Open(char* name,HV* hv_options=Nullhv)

void
DB::DESTROY()

void
DB::Put(char* key,char* value=NULL)

const char* 
DB::Get(const char * key)

void
DB::Delete(char * key)

Iterator*
DB::NewIterator(HV* hv_read_options=Nullhv);
	CODE:
		const char* CLASS = "Tie::LevelDB::Iterator";
		RETVAL = THIS->NewIterator(hv_read_options);
	OUTPUT:
		RETVAL

void
DB::Write(WriteBatch* batch, HV* hv_write_options=Nullhv)

MODULE = Tie::LevelDB		PACKAGE = Tie::LevelDB::WriteBatch

WriteBatch*
WriteBatch::new()

void
WriteBatch::Put(const char* key,const char* value)

void
WriteBatch::Delete(const char* key)

void
WriteBatch::DESTROY()

MODULE = Tie::LevelDB		PACKAGE = Tie::LevelDB::Iterator

Iterator*
Iterator::new()

void
Iterator::DESTROY()

void
Iterator::Seek(char* c_target)

void
Iterator::SeekToFirst()

void
Iterator::SeekToLast()

void
Iterator::Prev()

void
Iterator::Next()

bool
Iterator::Valid()

const char*
Iterator::key()

const char*
Iterator::value()

MODULE = Tie::LevelDB		PACKAGE = Tie::LevelDB

LevelDB*
LevelDB::new()

const char*
LevelDB::FETCH(const char* key)

void
LevelDB::STORE(const char* key,SV* sv_value)
	CODE:
		const char* cvalue = SvOK(sv_value) ? SvPV_nolen(sv_value) : NULL;
		THIS->STORE(key,cvalue);

void
LevelDB::DELETE(const char* key)

void
LevelDB::CLEAR()

bool
LevelDB::EXISTS(const char* key)

const char*
LevelDB::FIRSTKEY()

const char*
LevelDB::NEXTKEY(const char* lastkey)

int
LevelDB::SCALAR()

void
LevelDB::DESTROY()

LevelDB*
TIEHASH(const char* CLASS,const char* name,HV* hv_options=Nullhv)
  CODE:
    RETVAL = new LevelDB(name,hv_options);
  OUTPUT:
    RETVAL


