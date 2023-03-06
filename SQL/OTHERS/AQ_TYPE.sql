CREATE OR REPLACE TYPE aq_type AS OBJECT (
  id              NUMBER(22,0),
  pcid            NUMBER(22,0),
  new_bsaacid     CHAR(20),
  new_invisible   CHAR(1),
  new_pod         DATE,
  new_amnt        NUMBER(22,0),
  new_amntlc      NUMBER(22,0),
  new_pbr         CHAR(7),
  old_bsaacid     CHAR(20),
  old_invisible   CHAR(1),
  old_pod         DATE,
  old_amnt        NUMBER(22,0),
  old_amntlc      NUMBER(22,0),
  CONSTRUCTOR FUNCTION aq_type(a_id NUMBER DEFAULT NULL) RETURN SELF AS RESULT
);
/

CREATE OR REPLACE TYPE BODY aq_type IS
  CONSTRUCTOR FUNCTION aq_type(a_id NUMBER DEFAULT NULL) RETURN SELF AS RESULT IS
  BEGIN
    self.id := a_id;
    RETURN;
  END;
END;
/
