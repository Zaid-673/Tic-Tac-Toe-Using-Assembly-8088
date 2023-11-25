    org 0x0100

;hardcodes gameboard
board:  equ 0x0300

start:
    mov bx,board    
    mov cx, 16
    mov al, '1'

 ;displays the numbers & symbols that show players which key to press to get an input   
show_pattern:
    mov [bx], al
    inc al
    inc bx
    loop show_pattern

;starts building the board row by row
initialise_board:
    call show_board

    call first_row

    call get_input
    mov byte [bx],'X'

    call show_board

    call first_row

    call get_input
    mov byte [bx], 'O'

    jmp initialise_board

;makes the border between boxes clear and differenciates between boxes and symbols
show_board:
    mov bx,board

    call show_row
    call show_border
    mov bx, board+4

    call show_row
    call show_border
    mov bx, board+8

    call show_row
    call show_border
    mov bx, board+12

    jmp show_row

;seperates the rows using this symbol
show_row:
    call show_square
    mov al, '|'
    call display_letter

    call show_square
    mov al, '|'
    call display_letter
    
    call show_square
    mov al, '|'
    call display_letter

    call show_square

;instead of continously using ret from functions we can use this to automatically go to the next line
new_line:

    mov al,0x0d
    call display_letter

    ;similar to \n in c++
    mov al,0x0a
    jmp display_letter

;this will make the border on the intersections of the boxes as well as making the roof of the row tunnels
show_border:

    mov al, '-'
    call display_letter

    mov al, '+'
    call display_letter

    mov al, '-'
    call display_letter

    mov al, '+'
    call display_letter

    mov al,'-'
    call display_letter

    mov al, '+'
    call display_letter

    mov al,'-'
    call display_letter

    jmp new_line

;shows the full square of the board,(includes 16)
show_square:

    mov al, [bx]
    inc bx
    jmp display_letter

;acts as the main source to get input from our players
get_input:

    call read_keyboard

    cmp al, 0x1b		
    je exit	

    sub al, '1'	

    jc get_input	

    cmp al, 'F'	

    jnc get_input	

    cbw			; Expand AL to 16 bits using AH.

    mov bx, board	
    add bx, ax		
    mov al, [bx]

    cmp al, 'A'	

    jnc get_input	
    jmp new_line	

;acts as a termination subroutine and is added in various places so its easier to terminate when a player wins or the exit key (esc) is pushed
exit:
    int 0x20		

continue:
    ret

;shows individual letters, be it guiding symbol or 'X' or 'O'
display_letter:

	push ax
	push bx
	push cx
	push dx
	push si
	push di

	mov ah, 0x0e	; Load AH with code for terminal output
	mov bx, 0x000f	; Load BH with page zero and BL with color (only graphic mode)
	int 0x10		; Call the BIOS for displaying one letter

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	ret

;uses an interupt to read the key entered by user and then act accordingly
read_keyboard:
	push bx
	push cx
	push dx
	push si
	push di

	mov ah, 0x00	; Load AH with code for keyboard read
	int 0x16		; Call the BIOS for reading keyboard

	pop di
	pop si
	pop dx
	pop cx
	pop bx

	ret

;several subroutines to check the various scenarios for a player to win

mid2_col:
    mov al,[board+2]
    cmp al,[board+6]
    jne leftest_col
    cmp al,[board+10]
    jne leftest_col
    cmp al, [board+14]
    je won
second_row:
    mov al,[board+4]
    cmp al,[board+5]
    jne third_row
    cmp al,[board+6]
    jne third_row
    cmp al, [board+7]
    je won
first_diagonal:
    cmp al,[board+5]
    jne second_row
    cmp al,[board+10]
    jne second_row
    cmp al, [board+15]
    je won
third_row:    
    mov al,[board+8]
    cmp al,[board+9]
    jne righest_col
    cmp al,[board+10]
    jne righest_col
    cmp al, [board+11]
    je won
righest_col:
    mov al,[board+3]
    cmp al,[board+7]
    jne second_diagonal
    cmp al,[board+11]
    jne second_diagonal
    cmp al, [board+15]
    je won
leftest_col:
    cmp al,[board+4]
    jne first_diagonal
    cmp al,[board+8]
    jne first_diagonal
    cmp al, [board+12]
    je won

;displays the winning message, it can be customised as well
won:
    call display_letter
    mov al, ' ' 

    call display_letter
    mov al, 'W'

    call display_letter
    mov al, 'o'

    call display_letter
    mov al, 'n'

    call display_letter
    int 0x20

mid1_col:
    mov al,[board+1]
    cmp al,[board+5]
    jne righest_col
    cmp al,[board+9]
    jne righest_col
    cmp al, [board+13]
    je won

second_diagonal:
    cmp al,[board+6]
    jne continue
    cmp al,[board+9]
    jne continue
    cmp al, [board+12]
    je won

first_row:
    mov al,[board]
    cmp al,[board+1]
    jne leftest_col
    cmp al,[board+2]
    je won