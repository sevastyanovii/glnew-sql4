
BEGIN
    DBMS_AQADM.CREATE_QUEUE_TABLE(
        QUEUE_TABLE => 'BAL_QUEUE_TAB',
        MULTIPLE_CONSUMERS => FALSE,
        QUEUE_PAYLOAD_TYPE => 'AQ_TYPE',
        COMPATIBLE => '11.2.0',
        COMMENT => 'Queue table for async balance applying in posting processing.'
    );
END;
/

BEGIN
    DBMS_AQADM.CREATE_QUEUE(
        QUEUE_NAME => 'BAL_QUEUE',
        QUEUE_TABLE => 'BAL_QUEUE_TAB',
        MAX_RETRIES => 5,
        RETRY_DELAY => 10,
        COMMENT => 'Queue for async balance applying in posting processing.'
    );
end;
/

BEGIN
    DBMS_AQADM.START_QUEUE(AQ_PKG_CONST.C_NORMAL_QUEUE_NAME);
END;
/

BEGIN
    DBMS_AQADM.START_QUEUE(AQ_PKG_CONST.C_EXCEPTION_QUEUE_NAME, enqueue => false, dequeue => true);
END;
/