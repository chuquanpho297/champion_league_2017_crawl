import traceback
from base_connect import session_factory
from sqlalchemy.orm import scoped_session, lazyload, joinedload

class BaseRepo:

    def __init__(self):
        self.session = scoped_session(session_factory)

    def save(self, object):
        try:
            self.session.add(object)
            self.session.commit()
        except Exception as e:
            print(traceback.format_exc())
            self.session.rollback()
        finally:
            self.session.close()

    def save_all(self, objects):
        try:
            self.session.add_all(objects)
            self.session.commit()
        except Exception as e:
            print(traceback.format_exc())
            self.session.rollback()
        finally:
            self.session.close()

    def get_all(self, mapping_class, attr, lazy=True):
        try:
            datas = self.session.query(mapping_class).options(
                lazyload(attr) if lazy else joinedload(attr)).all()
            return datas
        except:
            print(traceback.format_exc())
        finally:
            self.session.close()

    def query(self, stmt):
        try:
            datas = self.session.execute(stmt, execution_options={
                                         "prebuffer_rows": True})
            return datas
        except Exception as e:
            print(traceback.format_exc())
        finally:
            self.session.close()
    def insert(self, stmt):
        try:
            data = self.session.execute(stmt)
            self.session.commit()
            return data.inserted_primary_key
        except Exception as e:
            print(traceback.format_exc())
        finally:
            self.session.close()
