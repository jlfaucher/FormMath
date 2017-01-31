; :encoding=IBM437:indentSize=8:tabSize=8:

; JLF jan 31 2017
; I don't remember the details, but I think this file was derived from the muSIMP
; delivered with muMATH-80, that I bought for my Apple ][ with Z80 card and CP/M.
; Was around 1982.
; This file contains an adaptation for muLISP-87.
;
; muSIMP is described by its authors (David Stoutemyer and Albert Rich, of the Soft Warehouse,
; Honolulu. Hawaii) as a "surface language" for muLISP.


		       ;*********************************
		       ;*				*
		       ;*  LANGAGE DE SURFACE : muSIMP	*
		       ;*				*
		       ;*********************************


; Force l'octet 'file input character mask' … 0FFh pour accepter tous les caractŠres de 000 … 255.
(CSMEMORY 846 255)			  ; Pour ne pas mettre le bit 7 … z‚ro


; Commentaires compatibles muSIMP : % ... %
(SET-MACRO-CHAR '\%
    ; Ignorer les caractŠres jusqu'au prochain '%' puis lire le '%' pour l'avaler.

    '(LAMBDA () (PEEK-CHAR '\%) (READ-CHAR))
    'COMMENT )


; FIRST de muLISP ne correspond pas au FIRST de muMATH : On force donc FIRST … faire la mˆme chose que CAR.
(MOVD CAR FIRST)


; Pour que les lettres soient dans l'ordre alphab‚tique.
(SETQ ALPHABET '(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z))


; Compactage maximum des espaces D-code lors de la d‚finition des fonctions.
(SETQ *CONDENSE* T)


;------------------------------------------------------------------------------
			 ; Fonctions d'entr‚es-sorties


(DEFUN READCHAR (EX1#)
    ;		  ÀÄÄ Nom de fichier
    ; Lecture bufferis‚e d'un caractŠre … partir de la source EX1#.
    ; SCAN <-- caractŠre lu.

    (SETQ SCAN (READ-CHAR EX1#)))


(DEFUN CONCHAR (*INPUT-FILE* *IGNORE-CASE*)
    ;		     ³		   ÀÄÄ Conversion en majuscule
    ;		     ÀÄÄ Depuis console
    ; Lecture non bufferis‚e et sans echo d'un caractŠre … partir de la console, convertit en majuscule.
    ; SCAN <-- caractŠre lu.

    (SETQ SCAN (CHAR-UPCASE (ASCII (READ-BYTE TRUE)))) )


(DEFUN READ-LISP (EX1# EX2# EX3# EX4# *EXACT-MODE*)
    ;		   ³	³    ³	 ---- ------------
    ;		   ³	³    ÀÄÄ Valeur … renvoyer si appui sur ESC
    ;		   ³	ÀÄÄ Tag … 'thrower' si appui sur ESC (pas de THROW si NIL)
    ;		   ÀÄÄ Nom de fichier
    ; Lecture bufferis‚e d'un objet LISP … partir de la source EX1#. Si appui sur ESC alors retour brutal au tag indiqu‚ si nonNIL.

    (SETQ *EXACT-MODE* TRUE)			    ; Pour que les fractions saisies ne soient pas arrondies
    (SETQ *THROW-TAG*)				    ; Pour savoir au retour si ESC a ‚t‚ press‚
    (CATCH 'RETURN
	((EQ (PEEK-CHAR TRUE) '\( )                 ; Si on va lire une liste alors...
	    (SETQ EX4# (READ EX1#))		    ;	on la lit et...
	    ((EQ (PEEK-CHAR TRUE) '\] )             ;   on regarde si le caractŠre suivant est un crochet car...
		(READ-CHAR EX1#) ) )		    ;	Mr Bug est pass‚ par l…. ex: (1 2] le crochet est encore dans le buffer !
	((EQ (PEEK-CHAR TRUE) '\] )                 ; Si le 1er caractŠre est un ] alors...
	    (SETQ EX4# (READ-CHAR EX1#)) )	    ;	Tiens ! encore Mr Bug... En effet le ] aurait ‚t‚ "aval‚" par READ !
	(SETQ EX4# (READ EX1#)) )		    ; Lecture classique sans problŠme
    ((EQ *THROW-TAG* 'RETURN)
	(SETQ EX4# EX3#)			    ; Pour renvoyer la valeur demand‚e en cas d'appui sur ESC
	(CLEAR-INPUT EX1#)			    ; Vide le buffer (indispensable !)
	(IF EX2# (THROW EX2# EX4#) EX4#) )	    ; ESC ==> retour brutal au tag indiqu‚ si tag nonNIL
    EX4# )					    ; Sinon renvoie l'objet lu


(SET-MACRO-CHAR '\þ '(LAMBDA () (READ) ))	    ; Pour ignorer þ lors d'un READ-LISP. ex: '(1 2 þ*TAB*) --> (1 2 *TAB*)


(DEFUN SCAN (EX1# EX2# EX3# *EXACT-MODE*)
    ;	      ³    ³	³   ------------
    ;	      ³    ³	ÀÄÄ Valeur … renvoyer si appui sur ESC
    ;	      ³    ÀÄÄ Tag … 'thrower' si appui sur ESC (pas de THROW si NIL)
    ;	      ÀÄÄ Nom de fichier
    ; Lecture bufferis‚e d'un token … partir de la source EX1#. Si appui sur ESC alors retour brutal au tag indiqu‚ si nonNIL.
    ; SCAN <-- token lu

    (SETQ *EXACT-MODE* TRUE)			    ; Pour que les fractions saisies ne soient pas arrondies
    (SETQ *THROW-TAG*)				    ; Pour savoir au retour si ESC a ‚t‚ press‚
    (CATCH 'RETURN
	(LOOP
	    ((NEQ (PEEK-CHAR TRUE) '\%))
	    (READ-CHAR)
	    (PEEK-CHAR '\%)
	    (READ-CHAR) )
	( ((EQ (PEEK-CHAR TRUE) '\þ)                ; Si þ alors les break-characters ne seront pas intercept‚s
	      (READ-CHAR EX1#)			    ; On saute le þ
	      (SETQ SCAN (READ-LISP EX1# EX2# EX3#)) ) ; READ-LISP pour avaler les break-characters. Convertit en MAJ si n‚cessaire.
	  ((EQ (PEEK-CHAR TRUE) '\" )               ; si " alors lecture chaŒne de caractŠres sans conversion en MAJ
	      (SETQ SCAN (READ EX1#)) ) 	    ; Ici le " n'a pas ‚t‚ retir‚ du buffer, donc il est intercept‚ par READ
	  (SETQ SCAN (READ-ATOM EX1#)) ) )	    ; Mode normal : les break-characters sont isol‚s (indispensable pour muMATH)
    ((EQ *THROW-TAG* 'RETURN)
	(SETQ SCAN EX3#)			    ; Pour renvoyer la valeur demand‚e en cas d'appui sur ESC
	(CLEAR-INPUT EX1#)			    ; Vide le buffer (indispensable !)
	(IF EX2# (THROW EX2# SCAN) SCAN) )	    ; ESC ==> retour brutal au tag indiqu‚ si tag nonNIL
    SCAN )					    ; Sinon renvoie l'objet lu


(DEFUN MUSIMP-SCAN (EX1#)
    ;		     ÀÄÄ Nom de fichier
    ; Fait appel … SCAN. Si appui sur ESC alors retour brutal … MUSIMP-AUX en renvoyant NIL.

    (SCAN EX1# 'MUSIMP-AUX) )


(DEFUN RDS (EX1# EX2#)
    ;	     ³	  ÀÄÄ Valeur de *INPUT-ECHO*
    ;	     ÀÄÄ Nom de fichier
    ; ReaD Select : pour ˆtre compatible avec muMATH et ˆtre utilisable facilement depuis muSIMP : pas de break-character dans le
    ; nom de la fonction, contrairement … open-input-file.

    (SETQ *INPUT-ECHO* EX2#)
    ((NULL EX1#)				    ; Si aucun fichier pr‚cis‚
	(CLOSE-INPUT-FILE) )			    ;	alors ferme tous les fichiers ouverts en lecture
    ((INPUT-FILE-P EX1#)			    ; Si le fichier est ouvert en lecture
	(INPUT-FILE EX1#) )			    ;	alors on le rend actif
    (OPEN-INPUT-FILE EX1#) )			    ; Sinon on l'ouvre en lecture


(DEFUN WRS (EX1# EX2# EX3#)
    ;	     ³	  ³    ÀÄÄ Valeur de *OUTPUT-ECHO*
    ;	     ³	  ÀÄÄ Overwrite
    ;	     ÀÄ Nom de fichier
    ; WRite Select : pour ˆtre compatible avec muMATH et ˆtre utilisable facilement depuis muSIMP : pas de break-character dans le
    ; nom de la fonction, contrairement … open-input-file.

    (SETQ *OUTPUT-ECHO* EX3#)
    ((NULL EX1#)				    ; Si aucun fichier pr‚cis‚
	(CLOSE-OUTPUT-FILE) )			    ;	alors ferme tous les fichiers ouverts en ‚criture
    ((OUTPUT-FILE-P EX1#)			    ; Si le fichier est ouvert en ‚criture
	(OUTPUT-FILE EX1#) )			    ;	alors on le rend actif
    (OPEN-OUTPUT-FILE EX1# EX2#) )                  ; Sinon on l'ouvre en ‚criture


(DEFUN OPTIONS (LEX1# EX1# LEX2# *PRINT-ESCAPE* *OUTPUT-FILE* *INTERRUPT-HOOK*)
    ;		  ³    ³   ----  -------------- ------------- ----------------
    ;		  ³    ÀÄÄ Message optionnel : string ou liste de string et d'objets divers
    ;		  ÀÄÄ Liste des choix possibles. La 1Šre lettre servira pour le choix

    ((NULL LEX1#) )				    ; Pas de blague! On plante tout si LEX1# vide (car ESC d‚sactiv‚)
    (TERPRI)
    (	((IDENTITY EX1#)			    ; Affiche le message optionnel si pr‚sent
	    (LOOP
		((ATOM EX1#)
		    ((NULL EX1#) )
		    (PRINC EX1#) )
		(PRINC (POP EX1#))
		(SPACES 1) )
	    (TERPRI) ) )
    (LOOP					    ; Affiche chaque choix possible et fabrique la liste des touches autoris‚es
	(PUSH (SUBSTRING (WRITE-STRING (POP LEX1#)) 0 0) LEX2#)
	((NULL LEX1#)
	    (PRINC '?)
	    (SPACES 1) )
	(PRINC *COMMA*)
	(SPACES 1) )
    (LOOP
	(TIME TRUE)				    ; A partir de maintenant, on a 7 secondes pour frapper une touche, sinon BEEP
	(CLEAR-INPUT TRUE)
	(LOOP
	    ((LISTEN TRUE) )			    ; Si une touche a ‚t‚ press‚e alors on va la lire, pas la peine de faire BEEP
	    ((> (TIME) 700)
		(BELL) ) )			    ; Le temps imparti est ‚coul‚, on d‚clenche la sirŠne
	((MEMBER (CONCHAR) LEX2#)
	    (æPRINT SCAN) )			    ; Si la touche press‚e est autoris‚e alors on l'affiche et sort de la boucle
	(BELL) )				    ; sinon BEEP
    SCAN )					    ; Valeur renvoy‚e : le symbole correspondant … la touche press‚e


(DEFUN WRITELIST LEX1#
  ; Affiche sur la mˆme ligne chaque ‚l‚ment de 1er niveau de LEX1# grƒce … la fonction WRITE.
  ((LISTP LEX1#)
    (LOOP
      ((NULL LEX1#))
      (WRITE (POP LEX1#)) ) ) )


;------------------------------------------------------------------------------
				    ; Divers


(SETQ FALSE 'NIL)
(SETQ TRUE  'T)


(DEFUN ONE (EX1#)
    (EQ EX1# 1) )


(DEFUN MINUS1 (EX1#)
    (EQ EX1# -1) )


(SETQ FILESLOADED)				    ; Initialise … vide la liste des fichiers sources charg‚s


(DEFUN TWODIGITS (EX1#)
  ; Si EX1# est un entier positif <= 99 alors renvoie une chaŒne de 2 caractŠres de la forme 0n ou EX1# si d‚j… deux chiffres.

  ((OR (NOT (INTEGERP EX1#)) (MINUSP EX1#) (> EX1# 99)) "??")
  ((< EX1# 10) (PACK* 0 EX1#))
  EX1#)


(DEFUN FILENAME (EX1# LEX1# *PRINT-ESCAPE* *PRINT-DOWNCASE*)
  ;		  ³   ----- -------------- ----------------
  ;		  ÀÄ Nom du fichier ou NIL pour lister les fichiers charg‚s
  ; Gestion des fichiers sources charg‚s pour connaŒtre le nom et la date de chaque fichier composant l'ensemble.
  ; La liste de ces fichiers est plac‚e dans FILESLOADED sous la forme d'une DTP-liste afin de respecter l'ordre de chargement.

  ((NULL EX1#)
    ; Affiche la liste des fichiers sources charg‚s qui ont ‚t‚ r‚f‚renc‚s.
    (SETQ LEX1# (CAR FILESLOADED))		    ; FILESLOADED est une DTP-liste
    (LOOP
      ((NULL LEX1#))
      (SETQ EX1# (POP LEX1#))			    ; EX1# <-- les informations du fichier courant
      (WRITELIST (FIRST EX1#) : )
      (SPACES (- 14 (SPACES)))
      (WRITELIST "Le" " " (TWODIGITS (FOURTH EX1#)) / (TWODIGITS (THIRD EX1#)) / (IF (SECOND EX1#) (SECOND EX1#) "????")
		 " " '… " " (TWODIGITS (FIFTH EX1#)) "h" " " (TWODIGITS (SIXTH EX1#)) "min" " " (TWODIGITS (SEVENTH EX1#)) "sec" )
      (TERPRI) ) )
  ((NAME EX1#)
    (SETQ FILESLOADED (TCONC FILESLOADED (CONS EX1# (FILE-DATE EX1#)))) ) )


;------------------------------------------------------------------------------
	       ; Fonctions de gestion des ‚v‚nements particuliers


(DEFUN MUSIMP-BREAK-AUX (BREAK *BRK*)
    ;			   ³	 ÀÄÄ Message optionnel : string
    ;			   ÀÄÄ Expression fautive ou valeur … retourner

    (LOOP
	(OPTIONS '("Continue" "Break" "Abort" "Top-level" "Restart" "System")
		 (IF *BRK* (LIST *BRK* "Break:" BREAK)) )
	((EQ SCAN 'C)                               ; Continue : reprend l'execution avec la valeur fournie
	    BREAK )
	((EQ SCAN 'B)                               ; Break : appelle un nouveau driver muSIMP (on monte d'un niveau)
	    (MUSIMP-AUX (ADD1 *LEVEL*)) )
	((EQ SCAN 'A)                               ; Abort : retour brutal au driver muSIMP sans changer de niveau
	    (SETQ *INPUT-FILE*)
	    (SETQ *OUTPUT-FILE*)
	    (SETQ *INPUT-ECHO*)
	    (SETQ *OUTPUT-ECHO*)
	    (THROW 'MUSIMP-AUX BREAK) )
	((EQ SCAN 'T)                               ; Top-level : retour brutal au driver muSIMP initial (niveau 0)
	    (SETQ *INPUT-FILE*)
	    (SETQ *OUTPUT-FILE*)
	    (SETQ *INPUT-ECHO*)
	    (SETQ *OUTPUT-ECHO*)
	    (THROW 'MUSIMP-TOP-LEVEL BREAK) )
	(   ((EQ SCAN 'R)                           ; Restart : si confirm‚ alors r‚-initialise l'interpr‚teur LISP. Adieu muSIMP!
	    (WRITE-STRING "Are you sure (Y/N)? ")
	    ((EQ (CONCHAR) 'Y)
		(æPRINT SCAN)
		(RESTART) ) ) )
	(   ((EQ SCAN 'S)                           ; System : si confirm‚ alors retour au MS-DOS
	    (WRITE-STRING "Are you sure (Y/N)? ")
	    ((EQ (CONCHAR) 'Y)
		(æPRINT SCAN)
		(SYSTEM) ) ) ) ) )


(DEFUN MUSIMP-BREAK (BREAK *BRK* EX1# EX2#)
    ;		       ³     ³	 ---- ----
    ;		       ³     ³	  ³    ÀÄÄ Op‚randes
    ;		       ³     ³	  ÀÄÄ Op‚rateur
    ;		       ³     ÀÄÄ Message optionnel : string
    ;		       ÀÄÄ Expression fautive ou valeur … retourner
    ; Met en place une gestion des exceptions compatible avec muMATH.

    ((EQ *BRK* '|Zero Divide|) (ZERODIVIDE BREAK) )
    ((EQ *BRK* '|Nonnumeric Argument|)
	(SETQ EX1# (CAR BREAK)
	      EX2# (CDR BREAK))
	((EQ EX1# '+)           (PLSTRAP EX2#) )
	((EQ EX1# '-)           (DIFTRAP EX2#) )
	((EQ EX1# '*)           (TIMTRAP EX2#) )
	((EQ EX1# '/)           (QUOTRAP EX2#) )
        ((EQ EX1# '<)           (LESTRAP EX2#) )
        ((EQ EX1# '<=)          (LESEQTRAP EX2#) )
        ((EQ EX1# '>)           (GRTTRAP EX2#) )
        ((EQ EX1# '>=)          (GRTEQTRAP EX2#) )
	((EQ EX1# 'MOD)         (MODTRAP EX2#) )
	((EQ EX1# 'DIVIDE)      (DIVTRAP EX2#) )
	(NONNUMERIC EX1# EX2#) )
    (MUSIMP-BREAK-AUX BREAK *BRK*) )


(DEFUN SYNTAX LEX1#
    ;	       ÀÄÄ Message optionnel : liste   ex: (syntax expr1 expr2 ...)

    (TERPRI)
    (WRITE-STRING "Syntax Error")
    (PRINC '!)
    (SPACES 2)
    (LOOP					    ; Affiche toutes les expressions de la liste
	((ATOM LEX1#) )
	(WRITE-STRING (POP LEX1#))
	(SPACES 1) )
    (TERPRI)					    ; Passe … la ligne suivante
    (LOOP					    ; Vide le buffer d'entr‚e
	(   ((AND *INPUT-ECHO* *INPUT-FILE*) )	    ;	en affichant ‚ventuellement les caractŠres vid‚s
	    (PRINC SCAN) )
	((OR (TERMINATOR SCAN)
	     (AND (NOT *INPUT-FILE*)
		  (EQ SCAN (ASCII 13)))) )
	(READCHAR) )
    (SETQ *INPUT-FILE*) 			    ; Console en entr‚e
    (THROW 'MUSIMP-AUX) )                           ; Retour brutal au driver muSIMP de niveau courant


(DEFUN ZERODIVIDE (LEX1#)
    (MUSIMP-BREAK-AUX LEX1# '|Zero Divide|) )


(DEFUN NONNUMERIC (EX1# LEX1#)
    (MUSIMP-BREAK-AUX (CONS EX1# LEX1#) '|Nonnumeric Argument|) )


(DEFUN NONTASK (EX1#)
    ; Il faut que EX1# soit un atome ou une liste commen‡ant par un symbole.
    ; Si pas v‚rifi‚ alors erreur de syntaxe sinon renvoie EX1#

    ((AND (NOT (ATOM EX1#)) (NOT (SYMBOLP (FIRST EX1#))))
	(SYNTAX "Nonfunctional Operand") )
    EX1# )


(DEFUN PLSTRAP (LEX1#)
    (NONNUMERIC '+ LEX1#) )


(DEFUN DIFTRAP (LEX1#)
    (NONNUMERIC '- LEX1#) )


(DEFUN TIMTRAP (LEX1#)
    (NONNUMERIC '* LEX1#) )


(DEFUN QUOTRAP (LEX1#)
    (NONNUMERIC '/ LEX1#) )


(DEFUN LESTRAP (LEX1#)
    (NONNUMERIC '< LEX1#) )


(DEFUN GRTTRAP (LEX1#)
    (NONNUMERIC '> LEX1#) )


(DEFUN MODTRAP (LEX1#)
    (NONNUMERIC 'MOD LEX1#) )


(DEFUN DIVTRAP (LEX1#)
    (NONNUMERIC 'DIVIDE LEX1#) )


(MOVD 'UNDEFINED 'UNDEFINED-FUNCTION)		    ; Sauvegarde la fonction UNDEFINED de muLISP


(DEFUN UNDEFINED LEX1#
    ;		  ÀÄÄ expression fautive (expr ...)  : expr n'est pas une fonction d‚finie
    ; Suivant la valeur de UNDEFINED, renvoie (expr ...) ou provoque un BREAK.
    ; Il est n‚cessaire d'‚valuer les arguments car muLISP ne le fait pas.

    (SETQ LEX1# (CONS (POP LEX1#) (MAPCAR 'EVAL LEX1#)))
    ((IDENTITY UNDEFINED)
	LEX1# )
    (APPLY 'UNDEFINED-FUNCTION LEX1#) )

(SETQ UNDEFINED T)


;------------------------------------------------------------------------------
		   ; Fonctions d'analyse syntaxique de muSIMP


(SETQ *DELIMITER* '(EXIT ENDLOOP ENDBLOCK ENDFUN ENDSUB \) \, ))

(SETQ *TERMINATOR* '( \; $ & _ ))

(SETQ *COMMA* '\, )

(SETQ *LPAR* '\( )

(SETQ *RPAR* '\) )


(DEFUN DELIMITER (EX1#)
    (OR (MEMBER EX1# *TERMINATOR*) (MEMBER EX1# *DELIMITER*)) )


(DEFUN TERMINATOR (EX1#)
    (MEMBER EX1# *TERMINATOR*) )


(DEFUN READLIST (EX1#)
    ;		 ----
    ; Lecture d'une liste sous la forme (expr1, expr2, ..., exprn) ou simplement d'un atome.
    ; Ici on reconnait la notation liste plut“t que la notation math‚matique utilis‚e habituellement par muSIMP.

    (LOOP					    ;Saute les virgules
	((NOT (EQ EX1# *COMMA*)) )
	(SETQ EX1# (MUSIMP-SCAN)) )
    ((EQ EX1# *RPAR*)				    ; Si ')' alors erreur de syntaxe
	(SYNTAX) )
    ((NOT (EQ EX1# *LPAR*))			    ; Si pas '(' alors c'est un atome
	((AND (NUMBERP (MUSIMP-SCAN)) (EQ EX1# '-))
	    (SETQ EX1# (- SCAN))
	    (MUSIMP-SCAN)
	    EX1# )
	EX1# )
    (LOOP					    ; Saute les virgules
	((NOT (EQ (MUSIMP-SCAN) *COMMA*)) ) )
    ((EQ SCAN *RPAR*)				    ; Si ')' alors fin de liste : retour
	(MUSIMP-SCAN)
	FALSE )
    (SETQ EX1# FALSE)
    (LOOP					    ; Ici traitement it‚ratif pour les ‚l‚ments de 1er niveau et traitement
	(SETQ EX1# (NCONC EX1# (LIST (READLIST SCAN)))) ; r‚cursif pour les sous-listes
	((EQ SCAN *RPAR*)
	    (MUSIMP-SCAN)
	    EX1# )
	((EQ SCAN '\.)
	    (SETQ EX1# (NCONC EX1# (READLIST (MUSIMP-SCAN))))
	    ((EQ SCAN *RPAR*)
		(MUSIMP-SCAN)
		EX1# )
	    (SYNTAX) ) ) )


(DEFUN MATCH (EX1# DELIM LEX1#)
    ;	       ³     ³	 -----
    ;	       ³     ³	   ÀÄÄ Liste invers‚e des expressions analys‚es
    ;	       ³     ÀÄÄ D‚limiteur … atteindre. ex: BLOCK ... ENDBLOCK
    ;	       ÀÄÄ Objet d‚j… lu par l'analyseur syntaxique.

    (SETQ SCAN EX1#)
    (	((EQ SCAN *COMMA*)			    ; Saute la virgule si n‚cessaire
	    (MUSIMP-SCAN) ) )
    (LOOP
	((EQ SCAN DELIM)			    ; Si on a atteint le d‚limiteur recherch‚
	    (MUSIMP-SCAN)			    ;	  Lit l'expression suivante
	    (REVERSE LEX1#) )			    ;	  Renvoie la liste des expressions encadr‚es (dans le bon ordre!)
	((DELIMITER SCAN)			    ; On a atteint un d‚limiteur, mais ce n'est pas le bon
	    (SYNTAX DELIM "not found") )	    ;	  --> erreur de syntaxe
	(PUSH (PARSE SCAN 0) LEX1#)		    ; Empile une nouvelle expression dans la liste des expressions rencontr‚es
	((EQ SCAN DELIM)			    ; Si on a atteint le d‚limiteur recherch‚
	    (MUSIMP-SCAN)			    ;	  Lit l'expression suivante
	    (REVERSE LEX1#) )			    ;	  Renvoie la liste des expressions encadr‚es (dans le bon ordre!)
	((NOT (EQ SCAN *COMMA*))		    ; Il faut obligatoirement une virgule entre chaque expression
	    (SYNTAX DELIM "or comma not found") )   ;	  sinon erreur de syntaxe
	(MUSIMP-SCAN) ) )			    ; Saute la virgule


(DEFUN PARSE (EX1# RBP EX2#)
    ;	       ³    ³  ----
    ;	       ³    ÀÄÄ Coefficient de priorit‚ … droite de EX1#
    ;	       ÀÄÄ Objet d‚j… lu
    ; A partir de l'entr‚e courante, lit et analyse une expression complŠte, en incluant le token EX1# d‚j… lu.
    ; L'op‚rateur * implicite n'est pas accept‚ si OPERATORTIME est … faux (ce qui est le cas lors d'une analyse de fonction).
    ; Renvoie l'objet r‚sultant non ‚valu‚.

    ((DELIMITER EX1#)
	(SYNTAX EX1# "used as variable") )
    (	((GET 'PREFIX EX1#)                          ; Si EX1# est un pr‚fixe
	    (SETQ EX1# (EVAL (GET 'PREFIX EX1#))) )  ;     alors on applique la propri‚t‚ rattach‚e
	((GET 'LBP EX1#)                             ; Si EX1# a un coef de priorit‚ … gauche, c'est que c'est un op‚rateur infixe
	    (SYNTAX EX1# "used as prefix operator") ); ou postfixe
	(MUSIMP-SCAN)
	((AND (GET 'RBP EX1#) (NOT (EQ SCAN *LPAR*)))
	    (SETQ EX1# (LIST EX1# (PARSE SCAN (GET 'RBP EX1#)))) ) )
    (LOOP
	(SETQ EX2# SCAN)
	((DELIMITER EX2#) EX1# )
	((AND OPERATORTIME (NOT (GET 'LBP EX2#)) (NOT (< RBP (GET 'LBP '*))))
	    EX1# )
	((AND (GET 'LBP EX2#) (NOT (< RBP (GET 'LBP EX2#))))
	    EX1# )
	((AND OPERATORTIME (EQ EX2# *LPAR*) (NOT (SYMBOLP EX1#)) (NOT (< RBP (GET 'LBP '*))))
	    EX1# )
	(   ((GET 'INFIX EX2#)                                  ; Si op‚rateur infix‚ avec traitement particulier
		(SETQ EX1# (EVAL (GET 'INFIX EX2#))) )          ; alors applique ce traitement
	    (NONTASK EX1#)					; V‚rifie que EX1# est un atome ou une liste du type (symbole ...)
	    ((GET 'RBP EX2#)
		((GET 'LBP EX2#)
		    ; Ici l'op‚rateur EX2# est infix‚
		    ((AND (NOT (ATOM EX1#)) (EQ EX2# (FIRST EX1#)) (GET 'NARY EX2#))     ; Si op‚rateur … arguments multiples et
			(NCONC EX1#							 ; associativit‚ alors regroupe les
			       (LIST (NONTASK (PARSE (MUSIMP-SCAN) (GET 'RBP EX2#))))) ) ; arguments
		    (SETQ EX1# (LIST EX2# EX1# (NONTASK (PARSE (MUSIMP-SCAN)		 ; Ici op‚rateur infix‚ … deux arguments :
							    (GET 'RBP EX2#)))) ))        ; fabrique (op arg1 arg2)
		; Ici l'op‚rateur EX2# est pr‚fix‚. On va faire comme s'il y avait l'op‚rateur * entre EX1# et EX2#.
		((NOT OPERATORTIME) (SYNTAX "Operator not found"))
		((AND (NOT (ATOM EX1#)) (EQ '* (FIRST EX1#)))                       ; Si l'expression de droite est une multiplication
		    (NCONC EX1# 						    ; alors regroupe les arguments
			   (LIST (NONTASK (PARSE EX2# (GET 'RBP '*))))) )
		(SETQ EX1# (LIST '* EX1# (NONTASK (PARSE EX2# (GET 'RBP '*))))) )   ; Fabrique la multiplication
	    ((GET 'LBP EX2#)
		; Ici l'op‚rateur EX2# est postfix‚, donc il s'applique … l'expression de droite EX1#.
		(SETQ EX1# (LIST EX2# EX1#))
		(MUSIMP-SCAN) )
	    ; Ici l'objet suivant n'est pas un op‚rateur. On va faire comme s'il y avait l'op‚rateur * .
	    ((NOT OPERATORTIME) (SYNTAX "Operator not found"))
	    ((AND (NOT (ATOM EX1#)) (EQ '* (FIRST EX1#)))
		(NCONC EX1#
		       (LIST (NONTASK (PARSE EX2# (GET 'RBP '*))))) )
	    (SETQ EX1# (LIST '* EX1# (NONTASK (PARSE EX2# (GET 'RBP '*))))) ) ) )


; Op‚rateurs admettant un nombre quelconque d'arguments

(PUT 'NARY  '*	 TRUE)
(PUT 'NARY  '+	 TRUE)
(PUT 'NARY  '>	 TRUE)
(PUT 'NARY  '>=  TRUE)
(PUT 'NARY  '<	 TRUE)
(PUT 'NARY  '<=  TRUE)
(PUT 'NARY  'AND TRUE)
(PUT 'NARY  'OR  TRUE)


; Coefficient gauche des op‚rateurs infix‚s ou postfix‚s

(PUT 'LBP  '!	 160)
(PUT 'LBP  '^	 140)
(PUT 'LBP  '/	 120)
(PUT 'LBP  '*	 120)
(PUT 'LBP  '-	 100)
(PUT 'LBP  '+	 100)
(PUT 'LBP  '>	 80 )
(PUT 'LBP  '>=	 80 )
(PUT 'LBP  '<	 80 )
(PUT 'LBP  '<=	 80 )
(PUT 'LBP  'EQ	 80 )
(PUT 'LBP  'EQL  80 )
(PUT 'LBP  'NEQ  80 )
(PUT 'LBP  'NEQL 80 )
(PUT 'LBP  '=	 80 )
(PUT 'LBP  'AND  60 )
(PUT 'LBP  'OR	 50 )
(PUT 'LBP  '\(	 200)
(PUT 'LBP  ':	 180)


; Coefficient droit des op‚rateurs pr‚fix‚s ou infix‚s

(PUT 'RBP  '^	 139)
(PUT 'RBP  '/	 120)
(PUT 'RBP  '*	 120)
(PUT 'RBP  '-	 100)
(PUT 'RBP  '+	 100)
(PUT 'RBP  '>	 80 )
(PUT 'RBP  '>=	 80 )
(PUT 'RBP  '<	 80 )
(PUT 'RBP  '<=	 80 )
(PUT 'RBP  'EQ	 80 )
(PUT 'RBP  'EQL  80 )
(PUT 'RBP  'NEQ  80 )
(PUT 'RBP  'NEQL 80 )
(PUT 'RBP  '=	 80 )
(PUT 'RBP  'NOT  70 )
(PUT 'RBP  'AND  60 )
(PUT 'RBP  'OR	 50 )
(PUT 'RBP  ':	 20 )


; Traitements particuliers pour certains op‚rateurs infix‚s

(PUT 'INFIX '\(
    '(PROGN
	((SYMBOLP EX1#) 				    ; Si forme symbole (...
	    (CONS EX1# (MATCH (MUSIMP-SCAN) *RPAR*)) )	    ; alors c'est un appel de fonction
	((NOT OPERATORTIME) (SYNTAX "Operator not found"))
	(LIST '* EX1# (PARSE *LPAR* (GET 'LBP '*))) ) )     ; Fait comme s'il y avait l'op‚rateur *


(PUT 'INFIX ':
    '(PROGN
	((SYMBOLP EX1#) 				    ; Si EX1# est un symbole
	    ((OR (EQ EX1# 'FALSE) (EQ EX1# 'TRUE))	    ;	  et que c'est FALSE ou TRUE
		(SYNTAX "Symbol" EX1# "is reserved word") ) ; Alors erreur (pour ‚viter de gros problŠmes avec muSIMP et muMATH)
	    (LIST ': EX1# (PARSE (MUSIMP-SCAN) 20)) )
	(SYNTAX "Bad Assignment") ) )			    ; On ne peut assigner une valeur qu'… un symbole


(PUT 'INFIX '<					    ; Pour avoir l'op‚rateur infix‚ <=
    '(PROGN
	(MUSIMP-SCAN)
	((EQ SCAN '=) (LIST '<= EX1# (PARSE (MUSIMP-SCAN) 80)) )
	(LIST '< EX1# (PARSE SCAN 80)) ) )


(PUT 'INFIX '>					    ; Pour avoir l'op‚rateur infix‚ >=
    '(PROGN
	(MUSIMP-SCAN)
	((EQ SCAN '=) (LIST '>= EX1# (PARSE (MUSIMP-SCAN) 80)) )
	(LIST '> EX1# (PARSE SCAN 80)) ) )


; Traitements particuliers pour certains op‚rateurs pr‚fix‚s

(PUT 'PREFIX '-
    '(PROGN
	((SETQ EX2# (PARSE (MUSIMP-SCAN) 130))
	    ((NUMBERP EX2#)			    ; Si EX2# est un nombre
		(- EX2#) )			    ; alors on peut directement changer son signe
	    (LIST '- EX2#) ) ) )                    ; sinon on fabrique l'expression (- expr) qui n'est pas ‚valu‚e


(PUT 'PREFIX '+
    '(PARSE (MUSIMP-SCAN) 130) )


(PUT 'PREFIX 'LOOP
    '(CONS 'LOOP (MATCH (MUSIMP-SCAN) 'ENDLOOP)) )


(PUT 'PREFIX 'BLOCK
    '(PROGN
	((EQ (MUSIMP-SCAN) 'WHEN)                   ; Il faut obligatoirement un WHEN aprŠs le BLOCK. Structure (((test) f1...)...)
	    (CONS (PARSE SCAN 0)
		  (MATCH SCAN 'ENDBLOCK)) )
	(SYNTAX "BLOCK without WHEN") ) )


(PUT 'PREFIX 'WHEN
    '(PROGN
	((ATOM (SETQ EX1# (PARSE (MUSIMP-SCAN) 0))) ; si forme WHEN atome alors il faut utiliser (IDENTITY atome) sinon l'atome
	    (CONS (LIST 'IDENTITY EX1#)             ; serait consid‚r‚ comme un nom de fonction.
		  (MATCH SCAN 'EXIT)) )
	(CONS EX1# (MATCH SCAN 'EXIT)) ) )


(DEFUN PARSEDEF (EX1# EX2# KILLDEF EX3# OPERATORTIME)
    ;		  ³    ³      ³    ---- ------------
    ;		  ³    ³      ³ 	     ÀÄ * implicite pas autoris‚
    ;		  ³    ³      ÀÄ Flag indiquant si on ‚crase la d‚finition pr‚c‚dente (oui si vrai)
    ;		  ³    ÀÄ D‚limiteur de fin
    ;		  ÀÄ Type de la fonction
    ; Analyse la d‚finition d'une fonction. KILLDEF servira au moment du rattachement de la d‚finition au symbole.

    ((AND (SETQ EX3# (READLIST (MUSIMP-SCAN)))
	  (SYMBOLP EX3#))			    ; Si le nom de la fonction est pr‚cis‚...
	(LIST* EX1#				    ; (LAMBDA... ou (NLAMBDA...
	       KILLDEF
	       EX3#
	       (READLIST SCAN)			    ; ... alors il est forc‚ment suivi d'une liste de paramŠtres...
	       (MATCH SCAN EX2#)) )		    ; ... et du corps de la fonction d‚limit‚ par ENDFUN ou ENDSUB.
    (LIST* EX1# 				    ; Si le nom de la fonction n'est pas pr‚cis‚ alors c'est que EX3#
	   KILLDEF				    ; contient la liste des paramŠtres et il ne reste plus qu'… lire
	   EX3# 				    ; le corps de la fonction.
	   (MATCH SCAN EX2#)) )


(PUT 'PREFIX 'SUBROUTINE '(PARSEDEF NLAMBDA ENDSUB T))      ; Type NLAMBDA, termin‚ par ENDSUB, peut ‚craser d‚finition pr‚c‚dente


(PUT 'PREFIX 'WNDSUBROUTINE '(PARSEDEF NLAMBDA ENDSUB NIL)) ; Type NLAMBDA, termin‚ par ENDSUB, m‚moris‚ si pas d‚j… d‚fini


(PUT 'PREFIX 'FUNCTION '(PARSEDEF LAMBDA ENDFUN T))         ; Type LAMBDA, termin‚ par ENDFUN, peut ‚craser d‚finition pr‚c‚dente


(PUT 'PREFIX 'WNDFUNCTION '(PARSEDEF LAMBDA ENDFUN NIL))    ; Type NLAMBDA, termin‚ par ENDFUN, m‚moris‚ si pas d‚j… d‚fini


(DEFUN PARSEPROPERTY (KILLDEF)
    ;			ÀÄ Flag indiquant si on ‚crase la propri‚t‚ pr‚c‚dente
    ; Analyse une propri‚t‚ PROPERTY ou WNDPROPERTY. KILLDEF servira au moment du rattachement de la propri‚t‚ au symbole.

    ((AND (SYMBOLP (SETQ EX1# (READLIST (MUSIMP-SCAN)))) ; Le 1er argument doit ˆtre un symbole...
	  (SYMBOLP (SETQ EX2# (READLIST (MUSIMP-SCAN)))) ; Le 2Šme aussi...
	  (EQ SCAN *COMMA*))
	(LIST 'PUTPROP EX1# EX2# (PARSE (MUSIMP-SCAN) 0) KILLDEF) )
    (SYNTAX) )


(PUT 'PREFIX 'PROPERTY '(PARSEPROPERTY T))          ; Peut ‚craser la propri‚t‚ pr‚c‚dente


(PUT 'PREFIX 'WNDPROPERTY '(PARSEPROPERTY NIL))     ; M‚moris‚ si pas d‚j… une propri‚t‚ de rattach‚e


(PUT 'PREFIX '\'
     '(PROGN
	(   ((SYMBOLP (SETQ EX1# (READ-LISP FALSE 'MUSIMP-AUX)))        ; Si on quote un symbole
		((OR (EQ EX1# 'FALSE) (EQ EX1# 'TRUE))			;   et que ce symbole est FALSE ou TRUE
		    (SYNTAX "You cannot quote the symbol" EX1#) ) ) )	; alors erreur car n'aurait pas la signification voulue
	(MUSIMP-SCAN)
	(LIST 'QUOTE EX1#) ) )


(PUT 'PREFIX '\(
    '(PROGN
	((SETQ EX1# (PARSE (MUSIMP-SCAN) 0))
	    ((EQ SCAN *RPAR*)
		(MUSIMP-SCAN)
		EX1# )
	    (SYNTAX RPAR "not found") ) ) )


;------------------------------------------------------------------------------
			   ; Fonctions de d‚finition


(SETQ *REDEFINE* '("Abort" "Redefine"))


(DEFUN FLAGSAVE (EX1# EX2#)			    ; Pour extensions futures
    TRUE )


(DEFUN PUTPROP (NLAMBDA (EX1# EX2# EX3# KILLDEF EX4#)
    ;			  ³    ³    ³	   ÀÄ TRUE si property, FALSE si WNDPROPERTY
    ;			  ³    ³    ÀÄÄ Propri‚t‚
    ;			  ³    ÀÄÄ Indicateur
    ;			  ÀÄÄ Symbole
    ; Place dans la P-list de EX1# la propri‚t‚ EX3# sous l'indicateur EX1#, avec confirmation si d‚j… d‚fini et console en ligne.
    ; PUTPROP n'‚value pas ses arguments, renvoie EX1# ou NIL.

    (	((EQ (FIRST EX3#) 'LAMBDA)                                  ; Si PROPERTY sym1, sym2, FUNCTION... ou WNDFUNCTION
	  (SETQ KILLDEF (AND KILLDEF (SECOND EX3#)))		    ; Si PROPERTY sym1, sym2, FUNCTION alors KILLDEF <-- TRUE
	  (SETQ EX3# (CONS (FIRST EX3#) (RREST EX3#))) ) )	    ; Ote le flag KILLDEF de la d‚finition
    ((AND (SETQ EX4# (GET EX1# EX2#)) (NOT KILLDEF)) NIL)	    ; Si d‚j… d‚fini et pas KILLDEF alors n'‚crase pas d‚finition
    ((OR (EQUAL EX4# EX3#)					    ; Si d‚j… existant alors retour
	 (AND EX3# (EQUAL (GETD EX4#) EX3#)))
	EX1# )
    ((OR (NOT EX4#)
	 (NOT (ECHO))
	 (EQ (OPTIONS *REDEFINE* "Property already defined") 'R))
	(   ((NOT SAVE) )
	    (FLAGSAVE EX1# EX2#) )
	((EQ (FIRST EX3#) 'LAMBDA)                                  ; Si on place une fonction dans la P-list, alors on fabrique
	    (PUTD (PUT EX1# EX2# (PACK* EX1# EX2#)) EX3#)	    ;	  un nom de fonction qui va ˆtre plac‚ dans la P-list, le
	    EX1# )						    ;	  corps de la fonction ‚tant plac‚ dans le Dcode.
	(PUT EX1# EX2# EX3#)					    ; Sinon c'est la d‚finition classique d'une propri‚t‚.
	EX1# ) ) )


(DEFUN MAKDEF (EX1# LEX1# KILLDEF)
    ;		³     ³      ÀÄ Indique si on peut ‚craser la d‚finition pr‚c‚dente
    ;		³     ÀÄÄ corps de la fonction
    ;		ÀÄÄ Symbole auquel on rattache la fonction
    ; Rattache le corps de la fonction au symbole indiqu‚, avec confirmation si d‚j… d‚fini et console en ligne.

    ((AND (NOT KILLDEF) (GETD EX1# T)) NIL )			    ; Si d‚j… d‚fini et pas KILLDEF alors n'‚crase pas d‚finition
    ((EQUAL (GETD EX1#) LEX1#) EX1# )				    ; Si d‚j… existant et identique alors retour
    ((OR (NOT (GETD EX1# TRUE))
	 (NOT (ECHO))
	 (EQ (OPTIONS *REDEFINE* "Function already defined") 'R))
	(   ((NOT SAVE) )
	    (FLAGSAVE EX1#) )
	(PUTD EX1# LEX1#)					    ; Rattache le corps de la fonction au symbole.
	EX1# ) )


(DEFUN NLAMBDA (NLAMBDA LEX1#
    ;			  ÀÄÄ forme (flagKILLDEF symbole expr1 expr2 ... exprn)

    (MAKDEF (SECOND LEX1#) (CONS 'NLAMBDA (RREST LEX1#)) (FIRST LEX1#)) ) )


(DEFUN LAMBDA (NLAMBDA LEX1#
    ;			 ÀÄÄ forme (flagKILLDEF symbole expr1 expr2 ... exprn)

    (MAKDEF (SECOND LEX1#) (CONS 'LAMBDA (RREST LEX1#)) (FIRST LEX1#)) ) )


;------------------------------------------------------------------------------
	      ; Fonctions d'affichage d'expressions math‚matiques
	      ; 	et d'expressions ‚crites en muSIMP


; Cette fonction sera red‚finie dans FORMMATH.MUS.

(DEFUN PRTMATH (EX1#)
  (WRITE EX1#)
  (NEWLINE) )


;------------------------------------------------------------------------------
		     ; Driver du langage de surface muSIMP


(SETQ TERPRI 1)


(DEFUN BELL ()
    ((NOT BELL) )
    (TONE 800 50 ) )				    ; Si bip accept‚ alors BEEP


(DEFUN ECHO ()
    (OR (NOT *INPUT-FILE*) *INPUT-ECHO*) )	    ; Console en ligne ou echo actif


(DEFUN MUSIMP-AUX (*LEVEL* *INPUT-FILE* *EX1* *EX2* *OUTPUT-FILE*)
    ;		      ³    ------------ ----- ----- -------------
    ;		      ³ 	 ³			  ÀÄÄ Console en sortie
    ;		      ³ 	 ÀÄÄ Console en entr‚e
    ;		      ÀÄÄ Niveau courant de driver muSIMP
    ;
    ; Cette fonction est le coeur de muSIMP/muMATH :
    ;		   ÚÄÄÄÄÄÄÄÄÄÄÄ¿
    ;		   ³	       v
    ;		   ³	       ³
    ;		   ³	lecture/analyse
    ;		   ³	       ³
    ;		   ³	   ‚valuation
    ;		   ³	       ³
    ;		   ³	   affichage
    ;		   ³	       ³
    ;		   ³	       v
    ;		   ÀÄÄÄÄÄÄÄÄÄÄÄÙ

    (LOOP
	(CATCH 'MUSIMP-AUX
	    (SETQ *THROW-TAG*)			    ; Pour savoir plus tard si on est revenu normalement ou … cause d'un THROW
	    (	((ECHO) 			    ; ¿
		    (TERPRI TERPRI)		    ; ³
		    (	((ZEROP *LEVEL*) )	    ; ³  Si autoris‚ alors affiche le prompt muSIMP
			(PRINC *LEVEL*) )	    ; ³
		    (PRINC '?)                      ; ³           n? si n>0
		    (SPACES 1)			    ; ³ 	  ?  si n=0
		    ((NOT *INPUT-FILE*) 	    ; ³
			(BELL) ) )		    ; ³  Si console en ligne et si autoris‚ alors BEEP
		(PRINC '?) )                        ; Ù
	    (SETQ *EX1*)			    ; EX1 va recevoir l'expression … analyser
	    ((TERMINATOR (SETQ *EX2* (MUSIMP-SCAN)))		; ¿
		((AND (EQ *EX2* '\;) *INPUT-ECHO* *INPUT-FILE*) ; ³ Si ; $ & _ comme 1er caractŠre alors pas d'‚valuation
		    (BREAK @) ) )				; Ù Si fichier en entr‚e et expression r‚duite … ';' alors BREAK
	    (SETQ *EX1* (PARSE SCAN 0)) 	    ; EX1 <-- expression … ‚valuer
	    (SETQ *EX2* SCAN)			    ; ¿
	    ((NOT (TERMINATOR *EX2*))		    ; ³ V‚rifie que l'expression se termine par un ; $ & ou _
		(SYNTAX "Operator not found")	    ; ³ Si non alors considŠre l'expression comme incomplŠte
		(TERPRI) )			    ; Ù
	    (	((AND *INPUT-ECHO* *INPUT-FILE*)    ; ¿
		    (TERPRI) ) )		    ; Ù Saut de ligne si echo avec fichier en entr‚e
	    (	((AND (ECHO) (PLUSP TERPRI))	    ; ¿
		    (TERPRI (SUB1 TERPRI)) ) )	    ; Ù Sauts de lignes suppl‚mentaires si demand‚s
	    ((EQ *EX2* '_) )                        ; Si _ alors sort du CATCH pour pr‚parer retour niveau inf‚rieur
	    (SETQ @ (EVAL *EX1*))		    ; @ <-- ‚valuation de l'expression (tout se passe ici !)
	    ((EQ *EX2* '$) )                        ; Pas d'affichage du r‚sultat si $
	    (PRINC '@)                              ; ¿
	    (PRINC ':)                              ; ³ Affiche le prompt de r‚ponse (indique que l'‚valuation est termin‚e)
	    (SPACES 1)				    ; Ù L'affichage proprement dit peut prendre un certain temps en pr‚paration
	    (	((EQ *EX2* '\;)                     ; ¿
		    (PRTMATH @) )		    ; ³ Si ';' alors affichage math‚matique
                (WRITE @) (TERPRI) )                ; Ù sinon affichage LISP
	    (	((AND *INPUT-ECHO* *INPUT-FILE* (NOT (EQ (FIRST *EX1*) 'RDS)))
		    (BREAK @) ) ) )
	((EQ *EX2* '_) )                            ; Si _ alors sortie de la boucle infinie du driver courant
	(   ((EQ *THROW-TAG* 'MUSIMP-AUX)           ; Si on est revenu ici … cause d'un THROW alors saut de ligne
		(TERPRI) ) ) )			    ;	 (on ne sort pas de la boucle infinie)
    (EVAL *EX1*) )				    ; Renvoie au driver de niveau pr‚c‚dent le r‚sultat de la derniŠre ‚valuation


(DEFUN MUSIMP (*INPUT-ECHO* *OUTPUT-ECHO*
	       *INPUT-FILE* *OUTPUT-FILE*
	       BELL )
    ; Driver initial dont le r“le est de pr‚parer l'appel au driver muSIMP de niveau 0.
    ; Autre r“le important : permet de revenir directement au top-level lors d'un BREAK.

    (CSMEMORY 846 255)				    ; Force le 'file input character mask' … 0FFh
    (RDS)
    (WRS)
    (MOVD 'BREAK 'æBREAK)			    ; Sauvegarde le gestionnaire de BREAK de muLISP
    (MOVD 'MUSIMP-BREAK 'BREAK) 		    ; Met en place le gestionnaire de BREAK propre … muSIMP
    (MAPC					    ; Modifie les macro-caractŠres provoquant des erreurs de syntaxe
      '(LAMBDA (EX1#) (SET-MACRO-CHAR EX1# (LIST 'LAMBDA NIL (LIST 'QUOTE EX1#))))
      '( \) \, \] \; & $) )                         ; les caractŠres ";" "&" et "$" sont inclus car ils doivent ˆtre terminateurs
    (WRITE-STRING "muSIMP Surface Language For Symbolic Math Processing.")
    (UNWIND-PROTECT
	(LOOP
	    (CATCH 'MUSIMP-TOP-LEVEL
		(TERPRI)
		(SETQ @ (MUSIMP-AUX 0)) )
	    ((NEQ *THROW-TAG* 'MUSIMP-TOP-LEVEL) ) ); Si on n'est pas ici … cause d'un THROW alors sortie de la boucle infinie
	(MOVD 'æBREAK 'BREAK) ) 		    ; Remet en place le gestionaire de BREAK de muLISP
    @ ) 					    ; Renvoie … muLISP le r‚sultat de la derniŠre ‚valuation au sein de muSIMP.


(SETQ DRIVER 'MUSIMP)


;------------------------------------------------------------------------------
	   ; Mise en place des break-characters sp‚cifiques … muSIMP


(SETQ *BREAK-CHARS-MULISP* (GET-BREAK-CHARS))


(SET-BREAK-CHARS '( !  \" $  &  \' \( \) *  +  \, -  \. /  :  \; <  =  >  ?  [

		    \\ \] ^  _	\` {  }  ~  «  ¬  á  â	ã  ä  å  ç  è  é  ê  ë

		    ì  í  î  ï	ð  ñ  ò  ó  ô  õ  ö  ÷	ø ù ú û ü ý) )


;------------------------------------------------------------------------------
	       ; Compatibilit‚ avec les fonction de muSIMP/muMATH


(MOVD 'ZEROP    'ZERO)

(MOVD 'SYMBOLP  'NAME)

(MOVD 'INTEGERP 'INTEGER)

(MOVD 'NUMBERP  'NUMBER)

(MOVD 'DENOMINATOR 'DEN)

(MOVD 'NUMERATOR 'NUM)

(MOVD 'NULL     'EMPTY)

(MOVD 'EQUAL    '=)

(MOVD 'NCONC    'CONCATEN)

(MOVD 'ADJOIN   'æADJOIN)
(MOVD 'CONS     'ADJOIN)

(MOVD 'PLUSP    'POSITIVE)

(MOVD 'MINUSP   'NEGATIVE)

(MOVD 'CAAR     'FFIRST)

(MOVD 'CDAR     'RFIRST)

(MOVD 'CDDR     'RREST)

(MOVD 'CAAAR    'FFFIRST)

(MOVD 'CAADR    'FFREST)

(MOVD 'CADAR    'FRFIRST)

(MOVD 'CDAAR    'RFFIRST)

(MOVD 'CDADR    'RFREST)

(MOVD 'CDDAR    'RRFIRST)

(MOVD 'CDDDR    'RRREST)

(MOVD 'LAST     'LASTNODE)

(MOVD 'NTH      'NTHNODE)

(MOVD 'RPLACA   'REPLACEF)

(MOVD 'RPLACD   'REPLACER)

(MOVD 'NCONC    'CONCATEN)

(MOVD 'TCONC    'TADJOIN)

(MOVD 'EVENP    'EVEN)

(MOVD 'ODDP     'ODD)

(DEFUN ORDERED (EX1# EX2#)
    (LOOP
	((ATOM EX2#) (ORDERP EX1# EX2#))
	((ATOM EX1#) TRUE)
	((ORDERED (FIRST EX1#) (FIRST EX2#)) TRUE)
	((NOT (EQUAL (POP EX1#) (POP EX2#))) FALSE) ))

(MOVD 'SET      'ASSIGN)

(MOVD 'SETQ     ':)

(MOVD 'PACK     'COMPRESS)

(MOVD 'UNPACK   'EXPLODE)

(MOVD 'LENGTH   'æLENGTH)
(DEFUN LENGTH(EX1#)
    ((ATOM EX1#) (PRINT-LENGTH EX1#))
    (æLENGTH EX1#) )

(MOVD 'TRUNCATE 'QUOTIENT)                          ; Division entiŠre

(MOVD '/        'æ/)                                ; Division rationnelle

(MOVD 'FILE-READ-POSITION  'READPTR)

(MOVD 'FILE-WRITE-POSITION 'WRITEPTR)

(MOVD 'PRINT    'æPRINT)
(MOVD 'WRITE    'PRINT)

(MOVD 'æPRINT   'PRINTLINE)

(MOVD 'TERPRI   'NEWLINE)

(MOVD WRITE-STRING æWRITE-STRING)
(DEFUN WRITE-STRING (EX1# *PRINT-DOWNCASE*)
    ; Red‚fini pour conserver l'affichage majuscules/minuscule mˆme si *PRINT-DOWNCASE* est nonNIL.
    (æWRITE-STRING EX1#) )

(DEFUN LINELENGTH (EX1#)
    ((FILE-LINE-LENGTH EX1#))
    (FOURTH (MAKE-WINDOW)) )

(MOVD 'CLEAR-SCREEN 'CLRSCRN)

(MOVD 'SET-CURSOR   'CURSOR)

(MOVD 'APPLY    'æAPPLY)
(DEFUN APPLY (LEX1# LEX2#)
    ; muMATH fait un usage intensif de APPLY (FALSE, ...) or muLISP ne gŠre pas ce cas correctement.
    ((NULL LEX1#) NIL)
    (æAPPLY LEX1# LEX2#) )


;------------------------------------------------------------------------------

; Pour vider les variables systŠmes + ++ +++ * ** ***
NIL
NIL
NIL

(RETURN)
