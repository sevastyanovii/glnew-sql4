DELETE FROM od;
INSERT INTO od (curdate, phase, lwdate, lwdate_status) VALUES (trunc(sysdate) - 1, 'ONLINE', trunc(sysdate) - 2, 'OPEN');
