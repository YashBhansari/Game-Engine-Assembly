.MODEL SMALL
.STACK 100H

.DATA
	menuMsg db 0DH, 0AH, '1. Tic-Tac-Toe', 0DH, 0AH, '2. Guess the Number (0-9)', 0DH, 0AH, '3. Rock-Paper-Scissors', 0DH, 0AH, '4. Exit', 0DH, 0AH, 'Select a game (1-4):  $'
	ticTacToeMsg db 0DH, 0AH, 'Tic-Tac-Toe! Player: X, Comp: 0 $'
	guessTheNumberMsg db 0DH, 0AH, 'Guess the Number (0-9)! (Max guesses: 5) $'
	rockPaperScissorsMsg db 0DH, 0AH, 'Rock-Paper-Scissors! $'
	exitMsg db 0DH, 0AH, 'Exiting the game. Goodbye! $'

	RandomNumber db 0
	guessPrompt db 0DH, 0AH, 'Enter your guess (0-9): $'
	guessLowMsg db 0DH, 0AH, 'Too low! Try again. $'
	guessHighMsg db 0DH, 0AH, 'Too high! Try again. $'
	correctMsg db 0DH, 0AH, 'Congratulations! You guessed it! You won! $'
	maxGuessesMsg db 0DH, 0AH, 'Maximum guesses exceeded! You lost! $'
	gameOverMsg db 0DH, 0AH, 'Press any key to continue... $'

	rpsChoicePrompt db 0DH, 0AH, '1. Rock', 0DH, 0AH, '2. Paper', 0DH, 0AH, '3. Scissor', 0DH, 0AH, 'Choose (1-3):  $'
	
	tttChoicePrompt db 0DH, 0AH, 'Your turn: Choose your position (1-9): $'
	compTurnPrompt db 0DH, 0AH, 'Computer''s turn $'
	grid db 0DH, 0AH, 0DH, 0AH, ' 1 | 2 | 3 ', 0DH, 0AH, '-----------', 0DH, 0AH, ' 4 | 5 | 6 ', 0DH, 0AH, '-----------', 0DH, 0AH, ' 7 | 8 | 9 ', 0DH, 0AH, '$'
	pos db ' _________$'  
	reset_grid db 0DH, 0AH, 0DH, 0AH, ' 1 | 2 | 3 ', 0DH, 0AH, '-----------', 0DH, 0AH, ' 4 | 5 | 6 ', 0DH, 0AH, '-----------', 0DH, 0AH, ' 7 | 8 | 9 ', 0DH, 0AH, '$'
	reset_pos db ' _________$'  

	compWinMsg db 0DH, 0AH, 'Sorry! You Lost! $'
	playerWinMsg db 0DH, 0AH, 'Congratulations! You Won! $'
	tieMsg db 0DH, 0AH, 'It''s a Tie! $'

.CODE
MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

MainMenu:
	CALL ClearScreen
	LEA DX, menuMsg
	MOV AH, 09H
	INT 21H

	CALL GetInput

	CMP AL, '1'
	JE RunTicTacToe
	CMP AL, '2'
	JE RunGuessTheNumber
	CMP AL, '3'
	JE RunRockPaperScissors
	CMP AL, '4'
	JE ExitGame

	JMP MainMenu

RunTicTacToe:
    CALL ClearScreen
	LEA DX, ticTacToeMsg
	MOV AH, 09H
	INT 21H
	CALL TicTacToeGame
	JMP MainMenu

RunGuessTheNumber:
	CALL ClearScreen
	LEA DX, guessTheNumberMsg
	MOV AH, 09H
	INT 21H
	CALL GuessTheNumberGame
	JMP MainMenu

RunRockPaperScissors:
	CALL ClearScreen
	LEA DX, rockPaperScissorsMsg
	MOV AH, 09H
	INT 21H
	CALL RockPaperScissorGame
	JMP MainMenu

ExitGame:
	LEA DX, exitMsg
	MOV AH, 09H
	INT 21H
    CALL WaitForKeyPress
	MOV AX, 4C00H
	INT 21H

ClearScreen PROC
	MOV AX, 0600H
	MOV BH, 07H
	MOV CX, 0000H
	MOV DX, 184FH
	INT 10H
	RET
ClearScreen ENDP

GetInput PROC
    MOV AH, 01H        
    INT 21H            
    CMP AL, 08H        
    JE IgnoreBackspace 
    RET
IgnoreBackspace:
    MOV AH, 02H  
    MOV DL, 20H  
    INT 21H
    JMP GetInput 
GetInput ENDP

TicTacToeGame PROC
	CALL ResetGrid

	MOV AH, 09H
    LEA DX, grid
	INT 21H
	
	MOV AX, 0
	INT 1AH
	MOV AX, DX
	
	XOR DX, DX
	MOV BX, 2
	DIV BX

	CMP DL, 1
	JE PlayTurn

CompTurn:
	MOV AX, 0
	INT 1AH
	MOV AX, DX
	
	XOR DX, DX
	MOV BX, 9
	DIV BX
	ADD DL, 1
	MOV BL, DL
	MOV BH, 0
	mov cl, pos[bx]
	cmp cl, '_'
	JNE CompTurn
    mov pos[BX], '0'

	mov al, bl
	CALL GridCalc
    mov bl, al
    mov bh, 0
    mov grid[bx], '0'

	MOV AH, 09H
	LEA DX, compTurnPrompt
    INT 21H 
	LEA DX, grid
	INT 21H 

    CALL CheckWin
	CALL CheckEnd
	JMP PlayTurn

PlayTurn:
	MOV AH, 09H
	LEA DX, tttChoicePrompt
	INT 21H
tttInput:
	CALL GetInput
	CMP AL, '1'
	JL InvalidTTTInput
	CMP AL, '9'
	JG InvalidTTTInput
	MOV BL, AL
	SUB BL, '0'
	MOV BH, 0
	mov cl, pos[bx]
	cmp cl, '_'
	JNE InvalidTTTInput
    
    mov pos[BX], 'X'
	sub al, '0'
    CALL GridCalc   
    mov bl, al
    mov bh, 0
    mov grid[bx], 'X'

    LEA DX, grid
	MOV AH, 09H
	INT 21H 

    CALL CheckWin
	CALL CheckEnd
	CALL CompTurn

EndGame1:
	CALL WaitForKeyPress
	JMP MainMenu

InvalidTTTInput:
	MOV AH, 02H
    MOV dl, 08H
    INT 21H
    MOV DL, 20H
    INT 21H
    MOV DL, 08H
    INT 21H

    JMP tttInput

TicTacToeGame ENDP

GridCalc PROC
    dec al                

    mov bl, al
    mov cl, 4
    mul cl    

    mov dl, al

    mov al, bl            
    mov bl, dl
    mov cl, 3
    xor dl, dl            
    div cl                
    mov cl, 14
    mul cl     

    add al, bl
    add al, 5 
	RET
GridCalc ENDP

CheckWin PROC
    MOV AL, pos[1]
    CMP AL, pos[2]
    JNE NotWin1
    CMP AL, pos[3]
    JNE NotWin1          
    CMP AL, '_'
    JE NotWin1           

    JMP WinFound   

NotWin1:
	MOV AL, pos[4]
    CMP AL, pos[5]
    JNE NotWin2
    CMP AL, pos[6]
    JNE NotWin2          
    CMP AL, '_'
    JE NotWin2

    JMP WinFound

NotWin2:
	MOV AL, pos[7]
    CMP AL, pos[8]
    JNE NotWin3
    CMP AL, pos[9]
    JNE NotWin3          
    CMP AL, '_'
    JE NotWin3

    JMP WinFound

NotWin3:
	MOV AL, pos[1]
    CMP AL, pos[4]
    JNE NotWin4
    CMP AL, pos[7]
    JNE NotWin4          
    CMP AL, '_'
    JE NotWin4

    JMP WinFound

NotWin4:
	MOV AL, pos[2]
    CMP AL, pos[5]
    JNE NotWin5
    CMP AL, pos[8]
    JNE NotWin5          
    CMP AL, '_'
    JE NotWin5

    JMP WinFound

NotWin5:
	MOV AL, pos[3]
    CMP AL, pos[6]
    JNE NotWin6
    CMP AL, pos[9]
    JNE NotWin6          
    CMP AL, '_'
    JE NotWin6

    JMP WinFound

NotWin6:
	MOV AL, pos[1]
    CMP AL, pos[5]
    JNE NotWin7
    CMP AL, pos[9]
    JNE NotWin7          
    CMP AL, '_'
    JE NotWin7

    JMP WinFound

NotWin7:
    MOV AL, pos[3]
    CMP AL, pos[5]
    JNE NotWin8
    CMP AL, pos[7]
    JNE NotWin8          
    CMP AL, '_'
    JE NotWin8

    JMP WinFound

NotWin8:
	RET

WinFound:
	CMP AL, 'X'
	JE PlayerWinsTTT
ComputerWinsTTT:
	MOV AH, 09H
    LEA DX, compWinMsg
    INT 21H
	CALL EndGame1
PlayerWinsTTT:
	MOV AH, 09H
    LEA DX,	playerWinMsg
    INT 21H
	CALL EndGame1

CheckWin ENDP

CheckEnd PROC
    MOV CX, 10
    MOV BX, 1
CheckLoop:
    MOV AL, pos[BX]
    CMP AL, '_'
    JE ContinueGame
    INC BX
    LOOP CheckLoop
	MOV AH, 09H
    LEA DX,	tieMsg
    INT 21H
	CALL EndGame1
ContinueGame:
    RET
CheckEnd ENDP

ResetGrid PROC
    lea si, reset_grid      
    lea di, grid            

copy_grid_loop:
    mov al, [si]            
    mov [di], al
    inc si
    inc di
    cmp al, '$'             
    jne copy_grid_loop      

    lea si, reset_pos       
    lea di, pos             

copy_pos_loop:
    mov al, [si]            
    mov [di], al
    inc si
    inc di
    cmp al, '$'             
    jne copy_pos_loop       

    RET
ResetGrid ENDP

GuessTheNumberGame PROC
	MOV AX, 0
	INT 1AH
	MOV AX, DX
	
	XOR DX, DX
	MOV BX, 10
	DIV BX

	ADD DL, '0'
	MOV [RandomNumber], DL

	MOV CX, 0

GuessLoop:
	CMP CX, 5
	JE MaxGuessesExceeded

	LEA DX, guessPrompt
	MOV AH, 09H
	INT 21H

guessInput:
	CALL GetInput
	CMP AL, '0'
	JL InvalidGuessInput
	CMP AL, '9'
	JG InvalidGuessInput

	INC CX

	MOV BL, [RandomNumber]
	CMP AL, BL
	JE CorrectGuess
	JL GuessTooLow

GuessTooHigh:
	LEA DX, guessHighMsg
	MOV AH, 09H
	INT 21H
	JMP GuessLoop

GuessTooLow:
	LEA DX, guessLowMsg
	MOV AH, 09H
	INT 21H
	JMP GuessLoop

MaxGuessesExceeded:
	LEA DX, maxGuessesMsg
	MOV AH, 09H
	INT 21H
	JMP EndGame2

CorrectGuess:
	LEA DX, correctMsg
	MOV AH, 09H
	INT 21H
	JMP EndGame2

EndGame2:
	CALL WaitForKeyPress
	RET

InvalidGuessInput:
    MOV AH, 02H
    MOV dl, 08H
    INT 21H
    MOV DL, 20H
    INT 21H
    MOV DL, 08H
    INT 21H
	
    JMP guessInput

GuessTheNumberGame ENDP

WaitForKeyPress PROC
	LEA DX, gameOverMsg
	MOV AH, 09H
	INT 21H
	
	MOV AH, 01H
	INT 21H
	RET
WaitForKeyPress ENDP

RockPaperScissorGame PROC
	MOV AX, 0
	INT 1AH
	MOV AX, DX
	
	XOR DX, DX
	MOV BX, 3
	DIV BX

	ADD DL, '1'
	MOV [RandomNumber], DL

	LEA DX, rpsChoicePrompt
	MOV AH, 09H
	INT 21H

rpsInput:	
	CALL GetInput
	CMP AL, '1'
	JL InvalidRPSInput
	CMP AL, '3'
	JG InvalidRPSInput
	
	MOV BL, [RandomNumber]
	
	ADD AL, 3	
	SUB AL, BL
	MOV BL, 3
	DIV BL

	CMP AH, 1
	JE PlayerWinsRPS
	JL TieGameRPS

ComputerWinsRPS:
	LEA DX, compWinMsg
	MOV AH, 09H
	INT 21H
	JMP EndGame3

PlayerWinsRPS:
	LEA DX, playerWinMsg
	MOV AH, 09H
	INT 21H
	JMP EndGame3

TieGameRPS:
	LEA DX, tieMsg
	MOV AH, 09H
	INT 21H

EndGame3:
	CALL WaitForKeyPress
	RET

InvalidRPSInput:
    MOV AH, 02H
    MOV dl, 08H
    INT 21H
    MOV DL, 20H
    INT 21H
    MOV DL, 08H
    INT 21H

    JMP rpsInput
	
RockPaperScissorGame ENDP

END MAIN