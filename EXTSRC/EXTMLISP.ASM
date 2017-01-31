; :encoding=IBM437:indentSize=8:tabSize=8:
;---------------------------------------------------------------------------------------------------------------------------------
;  Fichier: EXTæLISP.ASM  19/03/89  06/04/89  31/07/89
;---------------------------------------------------------------------------------------------------------------------------------


	page 66, 132


	AdrLoad EQU 9B00H			    ; Adresse de chargement dans muLISP


	evenIP MACRO
	; Aligne le compteur ordinal sur une adresse paire, en n'utilisant au pire qu'un octet et non pas trois comme MASM !
	if ($ - debut) mod 2
	    ; Si on est align‚ sur une adresse impaire alors il faut ins‚rer un NOP
	    nop
	endif
	endm


	odd MACRO
	; Aligne le compteur ordinal sur une adresse impaire.
	if ($ - debut) mod 2
	    ; Si on est align‚ sur une adresse impaire, c'est bon.
	else
	    ; sinon il faut ins‚rer un nop.
	    nop
	endif
	endm


	; Variables du BIOS dans le segment 0
	Crt_Start	EQU 44EH		    ; Adresse de d‚but de page d'‚cran relative … l'adresse absolue de la page 0


	; Adresses de symboles
	NIL		EQU 100H
	T		EQU 102H
	PRINT_DOWNCASE	EQU 336H
	PRINT_ESCAPE	EQU 338H
	AUTO_NEWLINE	EQU 32EH


	CODE SEGMENT
	CODE ENDS
	DATA SEGMENT
	DATA ENDS


	ASSUME CS: CODE, DS: DATA


	DATA SEGMENT				    ; ----------------------------------------------------------------------------


	; Variables dans le segment DS:
	org 0
	BASSYM		EQU 100H		    ; Base des symboles
	ENDSYM		DW  ?			    ; Fin des symboles
	ENDNUM		DW  ?			    ; Fin des nombres
	ENDATM		DW  ?			    ; Fin des atomes
	ENDCNS		DW  ?			    ; Fin des doublets
	MAXCNS		DW  ?			    ; Taille maxi de l'espace des doublets

			DW  ?
			DW  ?
			DW  ?

	DEFSEG		DW  ?			    ; Segment pointeurs fonction/longueur
	PNPSEG		DW  ?			    ; Segment pointeurs Pname/vecteur
	PNSSEG		DW  ?			    ; Segment des Pnames
	VECSEG		DW  ?			    ; Segment des vecteurs num‚riques

			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?

	BASSTK		EQU 400H		    ; Base de l'espace des piles
	BASCOD		DW  ?			    ; Fin des piles / base du Dcode
	ENDCOD		DW  ?			    ; Fin du Dcode
	MAXCOD		DW  ?			    ; Taille maxi du Dcode

	ENDSTR		DW  ?			    ; Fin de l'espace des Pnames
	MAXSTR		DW  ?			    ; Taille maxi de l'espace des Pnames

	ENDVEC		DW  ?			    ; Fin de l'espace des vecteurs num‚riques
	MAXVEC		DW  ?			    ; Taille maxi de l'espace des vecteurs

	BASFCB		DW  ?			    ; Base de l'espace des FCB dans CS
	IFCB		DW  ?			    ; Pointeur sur le SIF FCB
	OFCB		DW  ?			    ; Pointeur sur le SOF FCB
	ENDFCB		DW  ?			    ; Fin de l'espace des FCB dans CS

	THRVAL		DW  ?			    ; Valeur du THROW (0 si inactif)
	PRECSN		DW  ?			    ; Pr‚cision courante
	UNDFLO		DW  ?			    ; Underflow courant

	GCCTR		DW  ?			    ; Compteur de GC
	RACTR		DW  ?			    ; Compteur de r‚allocation

	ORICS		DW  ?			    ; Code segment initial

			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?

	PosReadFS	DW  ?			    ; Position courante lors de lecture depuis Pname

	WinLeftX	DW  ?			    ; Abscisse de d‚but de fenˆtre graphique
	WinTopY 	DW  ?			    ; Ordonn‚e de d‚but de fenˆtre graphique
	WinXs		DW  ?			    ; Nombre de colonnes graphiques
	WinYs		DW  ?			    ; Nombre de lignes graphiques
	Vmatrix 	DW  ?			    ; Nbre de pixels V par caractŠre
	Hmatrix 	DW  ?			    ; Nbre de pixels H par caractŠre

	WinTopRow	DW  ?			    ; Ligne haut fenˆtre
	WinLeftCol	DW  ?			    ; Colonne gauche fenˆtre
	WinRows 	DW  ?			    ; Nbre de lignes
	WinCols 	DW  ?			    ; Nbre de colonnes
	VposCurs	DW  ?			    ; Position verticale courante dans fenˆtre
	HposCurs	DW  ?			    ; Position horizontale courante dans fenˆtre

			DW  ?
	StkDpos 	DW  ?			    ; Position dans tables Dcode du segment de pile
	SegDcode	DW  6 DUP (?)		    ; Segments des diff‚rents espaces Dcode
	EndDcode	DW  6 DUP (?)		    ; Fin du Dcode pour l'espace correspondant

			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DW  ?
			DB  ?
			DB  ?

	RFSflag 	DB  ?			    ; Flag READ-FROM-STRING
			DB  ?
	UnreadFlag	DB  ?			    ; Flag caractŠre remis dans flot
	UnreadChar	DB  ?			    ; CaractŠre remis dans flot

			DW  ?
			DB  ?

	VideoPage	DB  ?			    ; Nø de page courante
	ForegroundColor DB  ?			    ; Couleur des caractŠres
	BackgroundColor DB  ?			    ; Couleur du fond


	DATA ENDS


	CODE SEGMENT				    ; ----------------------------------------------------------------------------


	; Variables dans le segment CS:
	ORG		350H
	SingleESCchar	DB  ?
	MultipleESCchar DB  ?

	ORG		37CH
	Crt_Rows	DW  ?
	Crt_Cols	DW  ?


	; Routines muLISP
	ORG		893H
	Recup1arg	LABEL	NEAR

	ORG		89CH
	Recup2arg	LABEL	NEAR

	ORG		8ABH
	Recup3arg	LABEL	NEAR

	ORG		8BAH
	Recup4arg	LABEL	NEAR

	ORG		93FH
	Val16bits	LABEL	NEAR

	ORG		1837H
	LowerChar	LABEL	NEAR

	ORG		1842H
	TestKANJI	LABEL	NEAR

	ORG		2B2AH
	LenVideoSymb	LABEL	NEAR

	ORG		2BEAH
	InitPname	LABEL	NEAR

	ORG		2C68H
	ConcatenChar	LABEL	NEAR

	ORG		5238H
	GetCursorLines	LABEL	NEAR

	ORG		5263H
	SetCursorLines	LABEL	NEAR

	ORG		57E5H
	TypeChar	LABEL	NEAR

	ORG		6584H
	PrintLF 	LABEL	NEAR

	ORG		660AH
	PrintCR 	LABEL	NEAR

	ORG		6636H
	PrintChar	LABEL	NEAR

	ORG		6969H
	GetAttrib	LABEL	NEAR

	ORG		6B00H
	GetMode 	LABEL	NEAR

	ORG		AdrLoad
Debut:


	; Les variables de l'extension muLISP.

        RepSymb         DW  ?                       ; Le nombre d'occurence d'affichage d'un symbole pour l'objet courant

	FormHeight	DW  ?			    ; Hauteur de la forme
	FormWidth	DW  ?			    ; Largeur de la forme
	ExtraLines	DW  ?			    ; Nbre de lignes affich‚es aprŠs la forme jusqu'au prompt

	StartRow	DW  ?			    ; ¿
	StartCol	DW  ?			    ; ³ Caract‚ristiques de la fenˆtre show-fast
	NbRows		DW  ?			    ; ³ La ligne d'‚tat est … la ligne StartRow + NbRows
	NbCols		DW  ?			    ; Ù
	CurLig		DW  ?			    ; ¿
	CurCol		DW  ?			    ; Ù Position courante du coin sup‚rieur gauche
	ShowFlag	DB  ?			    ; 0 si pas de visu rapide
	ShowStat	DB  ?			    ; 0 si pas de ligne d'‚tat
	ShowStatColor	DB  ?			    ; Attribut d'‚cran de la ligne d'‚tat

	StatLine	DB  " Line: ....  "
	StatCol 	DB  "Col: ....  "
			DB  "Quit: ESC  Move: ", 24, 25, 27, 26," PgUp PgDn Home End ^PgUp ^PgDn "
	StatEnd 	DB  13, 10

	StartForm	DW  ?			    ; Offset du 1er octet de la formC
	pForm		DW  ?			    ; Position courante dans formC
	EndForm 	DW  ?			    ; Offset du 1er octet aprŠs la formC

	Vidadr		DW  ?			    ; Segment ‚cran
	CGA		DB  ?			    ; Flag CGA
	Attrib		DB  ?			    ; Attribut courant


	odd
BREAKNAME PROC NEAR
	; BREAKNAME (symbole)
	; Renvoie vrai si l'argument est un symbole dont le Pname contient au moins un break-caractŠre.

	call Recup1arg
	cmp si, ENDSYM
	jb @F					    ; Si SI est un symbole
	mov di, NIL
	ret
@@:	push ds
	mov ds, PNPSEG
	mov di, [si]				    ; di <-- offset du Pname
	pop ds
	push ds
	mov ds, PNSSEG				    ; ds <-- segment du Pname
	mov cx, [di]				    ; cx <-- longueur du Pname
	jcxz BREAKNAME_NIL			    ; ChaŒne vide donc pas de break-caractŠre
	cmp cx, 1
	jz BREAKNAME_NIL			    ; Si un seul caractŠre alors pas de problŠme de relecture
	inc di					    ; Pour commencer … sauter le mot de longueur
BNloop: inc di
	mov al, [di]				    ; al <-- caractŠre courant
	mov bx, 0				    ; Base de table des types de caractŠres
	xlat es:[bx]				    ; al <-- type du caractŠre
	and al, 8
	jnz BREAKNAME_T 			    ; On vient de trouver un break-caractŠre
	loop BNloop				    ; Passe au caractŠre suivant
BREAKNAME_NIL:
	pop ds
	mov di, NIL
	ret
BREAKNAME_T:
	pop ds
	mov di, T
	ret
BREAKNAME ENDP


	odd
PRTFORM PROC NEAR
	; PRTFORM (formL, flag, extra-lines, ShowStatColor)
	; Renvoie T si la forme est correcte et si il y a assez de place, NIL sinon.

	call GetAttrib
	mov ShowStatColor, bl			    ; Attribut des caractŠres pour la ligne d'‚tat par d‚faut
	call Recup4arg				    ; SI <-- formL   DI <-- flag   BX <-- extra-lines  AX <-- ShowStatColor
	push si 				    ; Sauvegarde formL
	mov si, ax				    ; SI <-- ShowStatColor
	mov al, ShowStatColor			    ; Valeur par d‚faut
	call Val16bits				    ; AX <-- Val16bits(ShowStatColor) ou inchang‚
	mov ShowStatColor, al
	pop si					    ; Rappelle formL
	mov ShowFlag, 0
	cmp di, NIL
	je @F
	inc ShowFlag				    ; ShowFlag <-- 1
@@:	mov ax, 0				    ; Valeur par d‚faut de extra-lines
	xchg si, bx				    ; SI <-- extra-lines   BX <-- formL
	call Val16bits				    ; AX <-- Val16bits(extra-lines) ou inchang‚
	mov ExtraLines, ax
	evenIP
	call ExpandForm 			    ; Fabrique en fin d'espace Pname la formC … partir de la formL BX
	jb @F					    ; Si assez de place et forme correcte
	mov di, NIL
	ret
@@:	call ShowWinLimits			    ; Calcule les coordonn‚es de la fenˆtre show-fast
	call ShowSlow				    ; Affichage compatible tous mat‚riels et tous modes, non interactif
	cmp ShowFlag, 0
	je @F
	cmp ShowStat, 0
	je @F					    ; Si ShowStat nul alors pas besoin d'affichage interactif
	call ShowFast				    ; Affichage r‚serv‚ … l'IBM-PC en mode texte, interactif
@@:	mov di, T
	ret
PRTFORM ENDP


ExpandForm PROC NEAR
	; Transforme la formL BX en formC … la fin de l'espace des Pnames.
	; Bit CF <-- 1 si formL correcte et assez de place.

	mov di, offset FormHeight
	call EFarg
	jnb EFend
	mov di, offset FormWidth
	call EFarg
	jnb EFend
	mov di, 0
	call EFarg				    ; Juste pour v‚rifier r‚f‚rence gauche et avancer dans liste
	jnb EFend
	call EFarg				    ; Juste pour v‚rifier r‚f‚rence droite et avancer dans liste
	jnb EFend
	; Ici BX pointe sur la DTP-liste des lignes
	cmp bx, dx
	jnb @F
EFerror:					    ; Pas bon : BX n'est pas un doublet
	clc
	ret
@@:	mov bx, [bx]				    ; BX <-- la liste des lignes
	cmp bx, dx
	jb EFerror				    ; Si BX n'est pas un doublet
	call InitPname				    ; Met un double z‚ro … la fin de l'espace des Pnames
EFloop:
	mov si, [bx]				    ; Si <-- ligne courante
	mov [bp], bx				    ; ¿
	inc bp					    ; ³ Empile la position courante dans la formL
	inc bp					    ; Ù
	evenIP
	call ExpandLine
	dec bp					    ; ¿
	dec bp					    ; ³ D‚pile la position courante dans la formL
	mov bx, [bp]				    ; Ù
	jnb EFend				    ; Si forme incorrecte ou pas assez de place
	mov bx, es:[bx] 			    ; BX <-- (CDR BX)
	cmp bx, dx
	jnb EFloop				    ; Si pas fin de liste
	mov di, ENDSTR				    ; DI <-- offset de la formC, longueur incluse
	push ds
	mov ds, PNSSEG
	mov ax, [di]				    ; AX <-- longueur de la formC
	pop ds
	inc di
	inc di					    ; Fait pointer DI sur le 1er caractŠre
	mov StartForm, di
	add ax, di				    ; AX <-- offset du 1er octet aprŠs la formC
	mov EndForm, ax
	stc
EFend:	ret
EFarg:	cmp bx, dx
	jb EFerror				    ; Si BX n'est pas un doublet
	mov si, [bx]				    ; SI <-- (CAR BX)
	mov bx, es:[bx] 			    ; BX <-- (CDR BX)
	call Val16bits				    ; AX <-- Val16bits(SI) et bit CF <-- 1 si ok
	jnb @F					    ; Si SI n'est pas un small int positif
	test di, di
	stc
	jz @F
	mov cs:[di], ax 			    ; M‚morise la valeur … l'adresse indiqu‚e
@@:	ret
ExpandForm ENDP


ExpandLine PROC NEAR
	; Transforme la ligne SI en formC … la fin de l'espace des Pnames
	; Bit CF <-- 1 si forme correcte et assez de place

	mov bx, si
	mov di, 0
	call EFarg				    ; Juste pour v‚rifier longueur ligne et avancer dans liste
	jnb ELend
	; Ici BX pointe sur la DTP-liste des objets
	cmp bx, dx
	jnb @F
ELerror:					    ; Pas bon : BX n'est pas un doublet
	clc
	ret
@@:	mov bx, [bx]				    ; BX <-- la liste des objets
	cmp bx, dx
	jb ELerror				    ; Si BX n'est pas un doublet
ELloop: mov di, [bx]				    ; DI <-- (CAR BX) l'objet courant
	cmp di, dx
	jb ELerror				    ; Si l'objet n'est pas un doublet
        mov si, es:[di]                             ; SI <-- (CDR objet) le symbole ou (occ . symb)
	cmp si, ENDSYM
        jnb @F                                      ; SI n'est pas un symbole
        mov RepSymb, 1                              ; Une seule occurence
        jmp ELwrite
@@:     push si                                     ; Sauvegarde (occ . symb)
        mov si, [si]                                ; SI <-- le nbre d'occurence
        call Val16bits                              ; AX <-- Val16bits (SI) et bit CF <-- 1 si ok
        pop si                                      ; Rappelle (occ . symb)
        jnb ELend                                   ; Pas bon : L'occurence n'est pas un entier
        mov RepSymb, ax
        mov si, es:[si]                             ; SI <-- le symbole
        cmp si, ENDSYM
        jnb ELend                                   ; Pas bon : SI n'est pas un symbole
ELwrite:
	mov ax, [di]				    ; ¿
	xchg ax, word ptr ds:PRINT_ESCAPE	    ; Ù *PRINT-ESCAPE* <-- valeur du flag
	mov [bp], ax				    ; Empile ancienne valeur de *PRINT-ESCAPE*
	mov [bp+2], bx				    ; Empile position courante dans liste des objets
	add bp, 4
	evenIP
@@:     call WriteToPname                           ; SI est tenu … jour, mˆme si GC
        jnb @F                                      ; Si pas assez de place
        dec RepSymb
        jnz @B                                      ; Tant qu'il reste des occurences
        stc                                         ; Pour indiquer OK
@@:     pushf
	sub bp, 4
	mov bx, [bp+2]				    ; Restaure BX
	mov ax, [bp]				    ; ¿
	mov word ptr ds:PRINT_ESCAPE, ax	    ; Ù Restaure *PRINT-ESCAPE*
	popf
	jnb ELend				    ; Si pas assez de place
	mov bx, es:[bx] 			    ; BX <-- (CDR BX)
	cmp bx, dx
	jnb ELloop				    ; Si pas fin de liste
	mov al, 13
	even
	call WriteCharToPname
	jnb ELend				    ; Si pas assez de place
	mov al, 10
	even
	call WriteCharToPname
ELend:	ret					    ; Retour avec bit CF=1 = OK
ExpandLine ENDP


WriteToPname PROC NEAR
	; En entr‚e SI pointe sur un symbole. Envoie la repr‚sentation vid‚o vers le buffer Pname. Bit CF <-- 1 si OK.

	mov [bp], si				    ; ¿
	inc bp					    ; ³ Empile le symbole (indispensable … cause du GC)
	inc bp					    ; Ù
	call LenVideoSymb			    ; CX <-- longueur Pname   BX <-- adresse Pname
	mov si, bx				    ; SI <-- adresse Pname
	mov bx, 2				    ; BX <-- offset du 1er caractŠre par rapport … l'adresse du Pname
	jnb NoESCchar
	cmp cx, 1
	jnz NotSingleChar
	push ds
	mov ds, PNSSEG
	mov al, [si+bx] 			    ; AL <-- le caractŠre unique
	pop ds
	cmp al, 20H
	jz NotSingleChar			    ; Si espace, on ne peut pas l'afficher \
	mov di, ax				    ; Sauvegarde le caractŠre
	mov al, SingleESCchar
	evenIP
	call WriteCharToPname			    ; Envoie "\"
	jnb WTPend				    ; Pas assez de place
	mov ax, di				    ; Rappelle le caractŠre
	evenIP
	call WriteCharToPname
	jmp short WTPend
NotSingleChar:
	mov al, MultipleESCchar
	evenIP
	call WriteCharToPname			    ; Envoie "|"
	jnb WTPend				    ; Pas assez de place
	jcxz SendMultESC			    ; Si chaŒne vide alors envoie encore "|" puis retour
WTPloop1:
	push ds
	mov ds, PNSSEG
	mov al, [si+bx] 			    ; AL <-- caractŠre courant
	pop ds
	inc bx					    ; Passe au caractŠre suivant
	call TypeChar				    ; AH <-- type du caractŠre dans AL
	test ah, 6
	jz NotESCchar				    ; Si pas single ou multiple escape
	mov di, ax				    ; Sauvegarde le caractŠre
	mov al, SingleESCchar
	evenIP
	call WriteCharToPname
	jnb WTPend				    ; Pas assez de place
	mov ax, di				    ; Rappelle le caractŠre
NotESCchar:
	call TestKANJI
	jnb NotKANJI
	evenIP
	call WriteCharToPname			    ; Envoie le caractŠre pr‚fixe
	jnb WTPend				    ; Pas assez de place
	dec cx
	jz SendMultEsc				    ; Si fin de chaŒne
	push ds
	mov ds, PNSSEG
	mov al, [si+bx] 			    ; AL <-- caractŠre suivant
	pop ds
	inc bx					    ; Passe au caractŠre suivant
	evenIP
NotKANJI:
	call WriteCharToPname			    ; Envoie le caractŠre
	jnb WTPend				    ; Pas assez de place
	loop WTPloop1				    ; Et on boucle jusqu'… la fin de la chaŒne
SendMultESC:
	mov al, MultipleESCchar
	evenIP
	call WriteCharToPname			    ; Envoie "|"
	jmp short WTPend
NoESCchar:
	stc
	jcxz WTPend
WTPloop2:
	push ds
	mov ds, PNSSEG
	mov al, [si+bx] 			    ; AL <-- caractŠre courant
	pop ds
	inc bx					    ; Passe au caractŠre suivant
	evenIP
	call WriteCharToPname			    ; Envoie le caractŠre courant
	jnb WTPend				    ; Pas assez de place
	loop WTPloop2
WTPend: mov si, [bp-2]                              ; Pour que SI pointe sur le symbole au retour
        dec bp
	dec bp					    ; Met la pile LISP … jour
	ret
WriteToPname ENDP


WriteCharToPname PROC NEAR
	; Envoie le caractŠre AL vers le Pname de travail aprŠs l'avoir converti en minuscule si n‚cessaire. Bit CF <-- 1 si ok.
	; Fait en sorte que SI contienne toujours l'adresse correcte du Pname (mˆme si GC).
	; Remarques concernant ConcatenChar :
	;   AX BX CX et DI sont sauvegard‚s.
	;   SI est modifi‚
	;   DI est modifi‚ si bit CF=0 au retour (contient NIL)

	cmp word ptr ds:PRINT_DOWNCASE, NIL
	jz @F
	call LowerChar				    ; Convertit AL en minuscule
@@:	evenIP
	call ConcatenChar			    ; ConcatŠne le caractŠre AL au Pname de travail
	mov si, [bp-2]				    ; SI <-- le symbole (adresse exacte mˆme si GC a eu lieu)
	push ds
	mov ds, PNPSEG
	mov si, [si]				    ; SI <-- adresse du Pname
	pop ds
	ret
WriteCharToPname ENDP


ShowWinLimits PROC NEAR
	; Calcule les coordonn‚es de la fenˆtre d'affichage rapide (D‚pend de la position courante du curseur et de la fenˆtre
	; courante).

	mov ShowStat, 0 			    ; A priori pas de ligne d'‚tat
	mov ax, WinLeftCol
	add ax, HposCurs
	mov StartCol, ax			    ; Colonne gauche

	mov ax, WinCols
	sub ax, HposCurs
	mov NbCols, ax				    ; Nbre de colonnes

	cmp FormWidth, ax
	jbe LargeEnough
	mov ShowStat, 1 			    ; La formC est plus large que la fenˆtre ==> ligne d'‚tat
LargeEnough:
	mov ax, FormHeight
	inc ax
	mov bx, WinRows
	sub bx, ExtraLines
	jb Height2				    ; Il faut un show fast car les extra-lines d‚calent tout
	cmp ax, bx
	jbe Height1				    ; La formC loge en hauteur mais sa largeur impose peut-ˆtre un show-fast
	; Ici on sait que la formC ne loge pas verticalement dans la fenˆtre
Height2:
	cmp WinRows, 1
	ja Height5				    ; Si fenˆtre assez haute
	mov ShowStat, 0 			    ; Pas de fenˆtre show-fast
	ret					    ; Il faut au moins deux lignes dans la fenˆtre car ligne d'‚tat
Height5:
	mov ShowStat, 1
	cmp ax, WinRows
	jbe Height1				    ; La formC sans les extra-lines loge verticalement dans la fenˆtre
	; Ici la fenˆtre show-fast occupe toute la fenˆtre en hauteur
	mov ax, WinTopRow
	mov StartRow, ax
	mov ax, WinRows
	dec ax					    ; On n'inclut pas la ligne d'‚tat
	mov NbRows, ax
	ret
Height1: ; Ici on est s–r que la fenˆtre a au moins deux lignes car FormHeight <= WinRows - ExtraLines
	mov bx, ax
	dec bx
	mov NbRows, bx				    ; Car on ne doit pas ‚crire sur la ligne d'‚tat
	mov bx, WinRows
	sub bx, VposCurs
	cmp ax, bx
	jbe Height3				    ; Pas de scrolling donc le haut de la fenˆtre show-fast est la ligne courante
	mov bx, WinRows
	sub bx, ax
	jmp short Height4
Height3:
	mov bx, VposCurs
Height4:
	mov StartRow, bx
	ret
ShowWinLimits ENDP


ShowSlow PROC NEAR
	; Affichage compatible tous mat‚riels et tous modes, non interactif. Les lignes sont tronqu‚es … la largeur de la fenˆtre.
	; Il n'y a pas de limitation en hauteur : Toute la forme d‚file … l'‚cran. Pas de sortie sur l'imprimante. Seul CR-LF est
	; interpr‚t‚.

	mov ax, NIL
	xchg ax, word ptr ds:AUTO_NEWLINE	    ; *AUTO-NEWLINE* <-- NIL
	push ax 				    ; Empile l'ancienne valeur de *AUTO-NEWLINE*
	push dx
	push es
	mov es, PNSSEG				    ; Pour adresser la formC
	mov si, StartForm			    ; SI <-- adresse du d‚but de la formC
	cld					    ; En avan‡ant
	mov cx, StartCol
	sub cx, WinLeftCol			    ; CX <-- nø relatif de la 1Šre colonne de la fenˆtre show-fast
SSL_PrtForm:
	push cx
	sub cx, HposCurs
	jcxz NoIndent
Indent:
	mov al, 20H
	push cx
	push si
	call PrintChar
	pop si
	pop cx
	loop Indent
NoIndent:
	mov cx, NbCols
SSL_PrintLine:
	lods byte ptr es:[si]
	cmp al, 13
	jne @F
	cmp byte ptr es:[si], 10
	je SSL_CRLF
@@:	push cx
	push si
	call PrintChar
	pop si
	pop cx
	loop SSL_PrintLine
@@:	lods byte ptr es:[si]
	cmp al, 13
	jne @B
	cmp byte ptr es:[si], 10
	jne @B
SSL_CRLF:
	push si
	call PrintCR
	call PrintLF
	pop si
	pop cx					    ; Nø relatif de la 1Šre colonne de fenˆtre show-fast
	inc si					    ; Pour sauter le LF
	cmp si, EndForm
	jb SSL_PrtForm				    ; Si on n'est pas … la fin de la formC
	pop es
	pop dx
	pop word ptr ds:AUTO_NEWLINE
	ret
ShowSlow ENDP


ShowFast PROC NEAR
	; Affichage interactif r‚serv‚ aux IBM-PC et compatibles. Ne fonctionne qu'en mode texte.
	; Retour sans affichage si mode graphique.

	call GetCursorLines			    ; CX <-- ligne de d‚but et de fin du curseur.  BH <-- nø de page courante
	push cx 				    ; Sauvegarde
	mov cx, 0BFBFH				    ; Pour rendre le curseur invisible
	call SetCursorLines
	mov VidAdr, 0B800H			    ; Pas mono 7 par d‚faut
	mov CGA, 1				    ; CGA par d‚faut
	call isEGA
	jnc @F					    ; Si CGA ou MA
	dec CGA 				    ; Pas CGA
@@:	call GetMode				    ; AL <-- mode vid‚o courant
	cmp al, 3
	jbe @F					    ; Tout est OK
	cmp al, 7
	je TextB000
	ret					    ; On est en mode graphique. Pas de show-fast
TextB000:
	dec CGA 				    ; Pas CGA
	mov VidAdr, 0B000H
@@:	push ds
	xor ax, ax
	mov ds, ax				    ; Pour adresser le segment z‚ro
	mov ax, word ptr ds:Crt_Start		    ; AX <-- offset de page courante
	pop ds
	add VidAdr, ax				    ; Met … jour l'adresse r‚elle de la page
	mov CurCol, 0
	call CtrlPgDnKey			    ; On affiche la derniŠre page
NextKey:
	call GetChar				    ; Attend une touche sans ‚cho
	cmp al, 0
	je Extended				    ; Si code ‚tendu
	cmp al, 27
	jne NextKey				    ; Si pas ESC alors ignore la touche
	pop cx					    ; Rappelle les attributs du curseur
	mov bh, VideoPage
	call SetCursorLines			    ; Remet le curseur dans son ‚tat initial
	mov ShowStat, 0 			    ; Pas de ligne d'‚tat
	mov CurCol, 0
	jmp CtrlPgDnKey 			    ; Si ESC alors termin‚, r‚affiche la derniŠre page et retour

ExKeys	DB 71, 72, 73, 75, 77, 79, 80, 81, 115, 116, 117, 118, 132	; Codes des touches ‚tendues
LexKeys EQU $ - ExKeys + 1
ExTable DW HomeKey, UpKey, PgUpKey, LeftKey, RightKey, EndKey
	DW DownKey, PgDnKey, CtrlLeftKey, CtrlRightKey, CtrlEndKey
	DW CtrlPgDnKey, CtrlPgUpKey
	DW NoneKey

Extended:
	call GetChar
	push es
	push cs
	pop es					    ; ES <-- CS
	mov di, offset ExKeys			    ; DI <-- adresse de table des touches
	mov cx, LexKeys 			    ; CX <-- longeur table
	repne scasb				    ; Recherche la touche
	pop es
	sub di, (offset ExKeys) + 1
	shl di, 1				    ; Ajuste DI pour pointer dans le tableau d'adresses
	call ExTable[di]			    ; Appelle la routine correspondante
	jmp NextKey

HomeKey:	; D‚but de ligne
	xor cx, cx
	mov CurCol, cx
	jmp ShowPage

UpKey:		; Monte d'une ligne
	mov cx, -1
	jmp ShowPage

PgUpKey:	; Monte d'une page
	mov cx, NbRows
	neg cx
	jmp ShowPage

LeftKey:	; Recule d'un caractŠre
	cmp CurCol, 0
	je @F
	dec CurCol
	xor cx, cx
	jmp ShowPage
@@:	ret

RightKey:	; Avance d'un caractŠre
	mov ax, CurCol
	inc ax
	cmp ax, FormWidth
	jae @F
	inc CurCol
	xor cx, cx
	jmp ShowPage
@@:	ret

EndKey: 	; Fin de ligne
	push es
	mov es, PNSSEG				    ; ¿
	mov di, pForm				    ; Ù ES:DI <-- adresse de d‚but de la ligne courante
	xor cx, cx
	dec cx					    ; CX <-- 0FFFFH
	mov ax, 0A0DH
	cld
@@:	repne scasb				    ; ¿
	cmp es:[di], ah 			    ; ³
	jne @B					    ; ³ CX <-- longueur de la ligne
	inc cx					    ; ³
	inc cx					    ; ³
	neg cx					    ; Ù
	pop es
	cmp CurCol, cx
	jae GoAtEnd
	mov ax, cx
	sub ax, NbCols
	jnb @F
EndKeyRet:
	ret					    ; La fenˆtre est assez large pour contenir la ligne en largeur
@@:	cmp CurCol, ax
	jnb EndKeyRet				    ; Si la fin de la ligne est d‚j… … l'‚cran
GoAtEnd:
	sub cx, NbCols
	mov CurCol, cx
	xor cx, cx
	jmp ShowPage

DownKey:	; Descend d'une ligne
	mov cx, 1
	jmp ShowPage

PgDnKey:	; Descend d'une page
	mov cx, NbRows
	jmp ShowPage

CtrlLeftKey:	; Recule horizontalement d'une page
	mov ax, CurCol
	sub ax, NbCols
	jnb @F
	xor ax, ax
@@:	mov CurCol, ax
	xor cx, cx
	jmp ShowPage

CtrlRightKey:	; Avance horizontalement d'une page
	mov bx, FormWidth
	sub bx, NbCols
	jnb @F
	ret
@@:	mov ax, CurCol
	add ax, NbCols
	cmp ax, bx
	jbe @F
	mov ax, bx
@@:	mov CurCol, ax
	xor cx, cx
	jmp ShowPage

CtrlEndKey:	; Colonne la plus … droite de la forme
	mov ax, FormWidth
	sub ax, NbCols
	jb @F
	mov CurCol, ax
	xor cx, cx
	jmp ShowPage
@@:	ret

CtrlPgDnKey:	; Fin de forme (derniŠre ligne)
	mov ax, EndForm
	mov pForm, ax
	mov ax, FormHeight
	mov CurLig, ax
	mov cx, NbRows				    ; Pour monter d'une page
	neg cx
	jmp ShowPage

CtrlPgUpKey:	; D‚but de forme (1Šre ligne)
	mov ax, StartForm
	mov pForm, ax
	xor cx, cx
	mov CurLig, cx
	jmp ShowPage

NoneKey:	; Autres touches
	ret

ShowFast ENDP


ShowPage PROC NEAR
	; Affiche la page courante. En entr‚e CX = d‚placement ligne sign‚.

	push dx
	push ds
	push es
	mov es, PNSSEG				    ; ¿
	mov di, pForm				    ; Ù ES:DI <-- adresse dans formC
	or cx, cx
	jg Forward
	jl Backward
	jmp short Show
Backward:
	call GoBackward
	jmp short Show
Forward:
	call GoForward
Show:	call GetAttrib
	mov Attrib, bl
	mov si, di				    ; SI <-- adresse de d‚but de ligne courante
	mov ds, PNSSEG				    ; DS <-- segment de formC
	mov cx, NbRows				    ; Compteur de lignes
Show1:	mov ax, NbRows
	sub ax, cx				    ; AX <-- 0 1 2 ... NbRows-1
	push cx 				    ; Sauvegarde le nbre de lignes restant
	push ax 				    ; Sauvegarde le nø de ligne relatif
	mov ah, 13
	mov cx, CurCol
	jcxz Show2
	cld
SkipCol:
	lodsb
	cmp al, ah
	loopne SkipCol
	jne Show2				    ; On a saut‚ CurCol colonnes sans rencontrer de CR-LF
	cmp byte ptr [si], 10
	jne SkipCol				    ; Si pas CR-LF alors continue
	dec si					    ; Pour pointer sur CR
Show2:	pop ax					    ; Rappelle nø de ligne relatif
	call CellWrt				    ; Affiche ligne courante … la ligne nø AX et fait pointer SI sur ligne suivante
	pop cx					    ; Rappelle le nbre de lignes restant
	cmp si, EndForm
	jb Show3				    ; Si on n'a pas d‚pass‚ la fin de la formC
	dec si
	dec si					    ; Pour pointer sur CR-LF
Show3:	loop Show1
	mov si, offset StatEnd			    ; Pas de ligne d'‚tat par d‚faut
	cmp ShowStat, 0
	je @F					    ; Pas d'affichage de ligne d'‚tat
	mov ax, CurLig
	inc ax					    ; + 1 car part de z‚ro
	mov di, offset StatLine[10]
	mov cx, 4
	call BinToStr				    ; Convertit le nø de ligne en chaŒne de quatre caractŠres cadr‚s … droite
	mov ax, CurCol
	inc ax					    ; + 1 car part de z‚ro
	mov di, offset StatCol[8]
	mov cx, 4
	call BinToStr				    ; Convertit le nø de colonne en chŒne de quatre caractŠres cadr‚s … droite
	mov al, ShowStatColor
	mov Attrib, al
	mov si, offset StatLine 		    ; ¿
@@:	push cs 				    ; ³
	pop ds					    ; Ù DS:SI <-- adresse de la chaŒne de ligne d'‚tat
	mov ax, NbRows				    ; Nø relatif de la ligne d'‚tat
	call CellWrt
	pop es
	pop ds
	pop dx
	ret
ShowPage ENDP


CellWrt PROC NEAR
	; Ecriture dans m‚moire vid‚o de ligne courante et recherche ligne suivante.
	; En entr‚e : DS:SI = adresse dans formC.
	;	      AX = nø de ligne relatif … fenˆtre.

	sub dx, dx
	cmp CGA, 1
	jne NoScan
	mov dx, 03DAH
NoScan: mov es, VidAdr
	mov cx, NbCols				    ; CX <-- nbre de colonnes par ligne de fenˆtre
	add ax, StartRow			    ; AX <-- nø absolu de la ligne … remplir (0 … 24)
	mov bx, Crt_Cols
	shl bx, 1				    ; BX <-- nbre d'octets par ligne d'‚cran
	mul bl					    ; AX <-- adresse de d‚but de ligne par rapport … la page courante
	mov di, ax				    ; Di <-- adresse de d‚but de ligne
	mov ax, StartCol
	shl ax, 1
	add di, ax				    ; DI <-- adresse de la 1Šre colonne de la fenˆtre dans ligne
	mov ah, Attrib				    ; Attribut dans AH. Le caractŠre sera dans AL
	cld
MoveChar:
	lodsb					    ; AL <-- DS:[SI++]
	cmp al, 13
	jne MoveChar1				    ; Si pas CR
	cmp byte ptr [si], 10
	je FillSpc				    ; Si LF alors fin de ligne
MoveChar1:
	or dx, dx
	je MoveChar2				    ; Si pas CGA
	call Retrace				    ; CGA ==> ‚criture synchronis‚e
	loop MoveChar				    ; Tant qu'il reste des colonnes … remplir
	jmp short NextLine
MoveChar2:
	stosw					    ; ES:[DI++ ++] <-- AX
	loop MoveChar				    ; Tant qu'il reste des colonnes … remplir
	jmp short NextLine
FillSpc:
	inc si					    ; Saute le LF pour pointer sur d‚but de ligne suivante
	mov al, " "
	or dx, dx
	je Space2				    ; Si pas CGA
Space1: call Retrace				    ; CGA ==> ‚criture synchronis‚e
	loop Space1				    ; Tant qu'il reste des colonnes
	ret					    ; SI pointe d‚j… sur la ligne suivante
Space2: rep stosw				    ; Remplit les colonnes restantes avec des espaces
	ret					    ; SI pointe d‚j… sur la ligne suivante
NextLine:
	mov ah, 13
ChkCR:	lodsb
	cmp al, ah
	jne ChkCR				    ; Si pas CR alors continue recherche
	cmp byte ptr [si], 10
	jne ChkCR				    ; Si pas LF alors continue recherche
	inc si					    ; Pour sauter le LF
	ret
CellWrt ENDP


GoBackward PROC NEAR
	; Recule de CX lignes.
	; ES:DI = adresse de ligne courante.
	; Met … jour CurLig et pForm

	std					    ; En reculant
	neg cx					    ; Rend CX positif
	mov dx, cx				    ; Sauvegarde
	inc cx					    ; Car on doit sauter en plus le CR-LF de la ligne pr‚c‚dente
	mov al, 10				    ; LF
FindB:	push cx 				    ; Sauvegarde le compteur de lignes
	mov cx, di
	sub cx, StartForm
	dec di
FindB1: repne scasb
	jcxz AtStart				    ; On n'a pas trouv‚ de LF et on est en d‚but de formC
	cmp byte ptr es:[di], 13
	jne FindB1				    ; Si pas CR-LF
	pop cx
	loop FindB
	sub CurLig, dx
	inc di
	inc di					    ; Pour sauter CR-LF
	mov pForm, di				    ; Met … jour pForm
	ret
AtStart:
	pop cx					    ; Met la pile … jour
	mov CurLig, 0
	mov di, StartForm
	mov pForm, di
	ret
GoBackward ENDP


GoForward PROC NEAR
	; Avance de CX lignes.
	; En entr‚e : ES:DI = adresse de ligne courante. Doit imp‚rativement pointer dans la formC (pas juste aprŠs).
	; Met … jour CurLig et pForm.

	cld					    ; En avan‡ant
	mov dx, cx				    ; Sauvegarde
	mov al, 13				    ; CR
FindF:	push cx
	mov cx, EndForm
	sub cx, di				    ; CX <-- le nbre de caractŠres restants
	dec cx					    ; Car le LF ne doit pas ˆtre compt‚ (SCASB s'arrˆte sur CR et DI pointe sur LF)
FindF1: repne scasb
	jcxz AtEnd				    ; On n'a pas trouv‚ de CR et on est en fin de formC
	cmp byte ptr es:[di], 10
	jne FindF1				    ; Si pas CR-LF
	inc di					    ; Pour sauter LF
	pop cx
	loop FindF
	add CurLig, dx
	mov pForm, di				    ; Met … jour pForm
	ret
Atend:	pop cx					    ; Met la pile … jour
	mov di, pForm				    ; On n'avance pas car le d‚placement fait aller au-d‚l… de la fin de la formC
	ret
GoForward ENDP


Retrace PROC NEAR
	; Ecriture synchronis‚e dans m‚moire ‚cran.
	; En entr‚e : ES:DI = position dans m‚moire ‚cran.
	;	      AX = caractŠre et attribut.

	mov bx, ax				    ; Sauve le caractŠre/attribut
Lscan:	in al, dx
	shr al, 1
	jc Lscan				    ; Attend que le port soit au niveau bas
	cli
Hscan:	in al, dx
	shr al, 1
	jnc Hscan				    ; Attend que le port soit au niveau haut
	mov ax, bx				    ; Rappelle le caractŠre/attribut
	stosw					    ; M‚morise le caractŠre et son attribut
	sti
	ret
Retrace ENDP


isEGA PROC NEAR
	; D‚termine si l'affichage EGA est actif.
	; Bit CF <-- 1 si actif, 0 sinon.

	push dx
	push es
	mov ah, 12H				    ; Fonction interrogation d'‚tat
	mov bl, 10H				    ; Sous-fonction information EGA
	sub cx, cx				    ; Positionne les bits d'‚tats … z‚ro
	int 10H
	sub ax, ax				    ; Segment 0 et pas d'EGA par d‚faut
	jcxz NoEGA				    ; Si les bits d'‚tat sont encore … z‚ro alors pas d'EGA
	mov es, ax				    ; ES <-- 0
	test byte ptr es:[487H], 1000b		    ; Teste le bit d'activit‚
	jnz NoEGA				    ; Si … 1 alors affichage EGA pas actif
	stc					    ; Actif
NoEGA:	pop es
	pop dx
	ret
isEGA ENDP


GetChar PROC NEAR
	; Attend l'appui d'une touche sans ‚cho. AL <-- touche.
	push dx
	mov ah, 7
	int 21H
	pop dx
	ret
GetChar ENDP


BinToStr PROC NEAR
	; Convertit AX en chaŒne de caractŠres cadr‚s … droite.
	; DI pointe sur l'adresse de stockage du chiffre de droite.
	; CX contient la taille maxi de la chaŒne.

	push es
	push cs
	pop es					    ; ES <-- CS
	mov bx, 10				    ; Division par 10
	std					    ; En reculant (car cadr‚ … droite)
GetDigit:
	xor dx, dx				    ; RAZ du mot fort du dividende
	div bx					    ; AX <-- quotient  DX <-- reste
	add dl, "0"				    ; Convertit en ASCII
	push ax 				    ; Sauvegarde le quotient
	mov al, dl
	stosb					    ; Stocke le chiffre d‚cimal courant
	pop ax					    ; Rappelle le quotient
	or ax, ax				    ; Quotient nul ?
	loopnz GetDigit 			    ; Si quotient non nul et chaŒne pas remplie alors on continue
	mov al, " "
	rep stosb				    ; Compl‚mente avec des espaces … gauche
	pop es
	ret
BinToStr ENDP


fin:

longueur equ fin - debut


	CODE	ENDS


	END
