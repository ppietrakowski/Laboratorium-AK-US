
	ORG 800H  
	LXI H,WPR_OPERAND  
	RST 3
    RST 5

    LXI H,SYM_NOWALINIA
    RST 3

    MOV B,D
    MOV C,E     

ZNAK_DZIALANIA
    LXI H,WPR_DZIALANIE
    RST 3
    RST 2

    LXI H,SYM_NOWALINIA
    RST 3
    CPI '!'

    CZ NEGACJA
    JZ WYNIK
    
    CPI '+'
    JZ DODAWANIE

    JMP ZNAK_DZIALANIA

WYNIK
    LXI H,SYM_NOWALINIA
    RST 3

    LXI H,WYN_DZIALANIA
    RST 3

    CC WYNIK_Przen

    MOV A,B
    RST 4
    MOV A,C
    RST 4
	HLT  

WCZYTAJ_LICZBE
    LXI H,WPR_OPERAND2
    RST 5
    RET

NEGACJA
    MOV A,B
    CMA
    MOV B,A
    MOV A,C
    CMA
    MOV C,A
    RET

DODAWANIE
    CALL WCZYTAJ_LICZBE
    MOV A,C
    ADD E
    MOV C,A

    MOV A,B
    ADC D
    MOV B,A
    JMP Wynik
    
WYNIK_Przen
    MVI A,'1'
    RST 1
    RET

SYM_NOWALINIA    DB 10,13,'@'
WPR_OPERAND 	 DB 'Wprowadz operand',10,13,'@' 
WPR_DZIALANIE 	 DB 'Wprowadz znak dzialania(+ - !)',10,13,'@' 
WPR_OPERAND2 	 DB 'Wprowadz operand 2',10,13,'@' 
ZLE_DZIALANIE	 DB 'Wprowadzono zly znak. @' 
ZLE_DZIALANIE2 	 DB 'Wprowadz znak dzialania ponownie',10,13,'@'
WYN_DZIALANIA 	 DB 'Wynik: @'