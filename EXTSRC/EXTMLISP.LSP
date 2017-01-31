; :encoding=IBM437:indentSize=8:tabSize=8:
;----------------------------------------------------------------------------------------------------------------------------------
;  File : EXTæLISP.LSP	 07/04/89
;----------------------------------------------------------------------------------------------------------------------------------


(SETQ *READ-BASE* 16)

(CSMEMORY 34E 0FF)				    ; Pour reconnaŒtre les caractŠres de 128 … 255


(FUNCALL '(LAMBDA (OFFSET BYTES)
  (IF (NEQ (SETQ OFFSET (ALLOCATE (SETQ BYTES 751))) 9B00)
      (PROGN (TERPRI)
	     (WRITE-STRING "Adresse de chargement incorrecte")
	     (TERPRI))
      (IF (NEQ (BINARY-LOAD "EXTMLISP.BIN" OFFSET) BYTES)
	  (PROGN (TERPRI)
		 (WRITE-STRING "Fichier EXTMLISP.BIN non trouv‚ ou longueur incorrecte")
		 (TERPRI))
          (PROGN (PUTD 'BREAKNAME 9B71)
                 (PUTD 'SHOWFORM 9BAD)
		 (SETQ SHOWSTATCOLOR 70) ))) ))     ; La ligne d'‚tat est affich‚e en vid‚o invers‚e (blanc 7 sur noir 0)

(SETQ *READ-BASE* 0A)
