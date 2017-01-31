% :encoding=IBM437:indentSize=8:tabSize=8:
% To insert in the file LOG.ALG %

PROPERTY FORMMATH, LOG, FUNCTION (LEX1#),
  WHEN SECOND (LEX1#) EQ #E,
    FORMOPER ('LN, LIST(FIRST(LEX1#))), exit,
  WHEN SECOND (LEX1#) = LOGBAS,
    FORMOPER ('LOG, LIST(FIRST(LEX1#))), exit,
ENDFUN$

RDS()$
