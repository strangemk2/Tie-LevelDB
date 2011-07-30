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

class LevelDB {
private:
	leveldb::DB *db;
	void do_assert(leveldb::Status s) {
		if(!s.ok()) std::cerr << s.ToString() << std::endl; // die!
	}
public:
	LevelDB(char * name) { 
		leveldb::Options options;
		options.create_if_missing = true;
		// options.error_if_exists = true;
		do_assert(leveldb::DB::Open(options, name, &db));
	}

	void Put(char * key, char * cvalue) {
		std::string* value = new std::string(cvalue);
		do_assert(db->Put(leveldb::WriteOptions(), key, *value));
	}

	const char* Get(char * key) {
		std::string value;
		do_assert(db->Get(leveldb::ReadOptions(), key, &value));
		return value.c_str();
	}

	void Delete(char * key) {
		do_assert(db->Delete(leveldb::WriteOptions(), key));
	}
};

MODULE = Tie::LevelDB		PACKAGE = Tie::LevelDB		

LevelDB *
LevelDB::new(char * name)

void
LevelDB::DESTROY()

void
LevelDB::Put(char * key, char * value)

const char* 
LevelDB::Get(char * key)

void
LevelDB::Delete(char * key)

