package org.hibernate.query;

public interface QueryProducer {

  Query createNativeQuery(String sqlString);

  Query createQuery(String queryString);

  Query createSQLQuery(String queryString);
}
