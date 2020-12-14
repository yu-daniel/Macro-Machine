; Macro Machine!     

; Author: Daniel Yu
; Last Modified: 06/06/2020
; Course number/section: CS271-400
; Project Number: Program# 6                 Due Date: 06/07/2020
;
; Description: a program that displays the program title and author,
; and asks the user for 10 signed decimal integers that should fit in
; a 32-bit register. Any invalid input(s) is rejected and the user is 
; asked again for another input. The 10 valid input's sum and rounded 
; average will be displayed to the user, followed by a goodbye msg.
; Utilizes the system stack, procedures and macros to accomplish this.

INCLUDE Irvine32.inc

HI			= 32
ARRAYSIZE	= 10
MAX			= 2147483647
MIN			= 2147483648			
CONVERTER	= 4294967295
COLOR		= 14

; ------------------------------------------------------------------------
; getString macro	(requires askNum and a string as parameters)
;
; Description: displays askNum msg to window console, and grabs
; the user's input using ReadString.
;
; Preconditions: user input limited to 32-bit size, only ascii chars 0-9
; and + and - symbol. The + and - symbols are allowed only as first char
; of each str. 
;
; Receives: askNum 
; Returns: str length in eax, and user's input into userStr variable
; Postconditions / Registers changed: eax and userStr is filled
; ------------------------------------------------------------------------

; ------------------------------BEGIN CITED CODE-------------------------------
; Source: Lecture #26 slide #8
; 
; Line 87 & 88 is not part of the source. Those are added in addition to the 
; source functions, since the program requirements ask for it. 
; 
; Function explanation: like procedures, the macro pushes any involved registers
; to the stack. Next, the address of askNum msg is moved to edx, and the
; Irvine32 library's WriteString procedure prints the string out to the 
; windows console. Afterwards, userStr variable's offset is moved to edx,
; this is where the user's input would be stored. The HI constant contains 
; value of 32, which represents the maximum bits we allow the user to enter.
; The ReadString Irvine32 procedure reads the string provided by the user.

getString	MACRO	askNum, userStr
	push	ecx							; save registers to stack
	push	edx

	mov		edx, OFFSET askNum			; ask user to enter valid inputs
	call	WriteString

	mov		edx, OFFSET userStr			; save user's input to to userStr
	mov		ecx, HI						; set a size limit on the user's input
	call	ReadString

	pop		edx
	pop		ecx
	
ENDM

; ------------------------------------------------------------------------
; displayString macro	(a string as a parameter)
;
; Description: the parameter string is displayed to windows console
; using WriteString procedure from Irvine32's library.
;
; Preconditions: none
;
; Receives: string as a parameter from the stack 
; Returns: none
; Postconditions / Registers changed: none
; ------------------------------------------------------------------------

; ------------------------------BEGIN CITED CODE---------------------------------------
; Note: I actually came up with this code myself, but I saw it matches (almost) exactly 
; like the example in Lecture 26 slide #6. So I will cite it here. 
;
; Source: Lecture 26 slide #6
; Function explanation: the macro begins by saving any registers that would be used
; in the process to the stack, in this case edx. Then the address of the parameter
; string is moved to edx. Irvine32's WriteString procedure is called to prints the 
; input out to the windows console. Lastly pop restores the edx register.

displayString	MACRO	stringToDisplay
	push	edx
	mov		edx, OFFSET stringToDisplay	; takes the parameter string and displays it
	call	WriteString					; using WriteString
	pop		edx
ENDM
; -------------------------------END CITED CODE----------------------------------------


.data

	showTitle	BYTE	" Macro Machine! by written by 'Daniel Yu'",0
	showInstr	BYTE	" + Enter 10 'signed' decimal integers. ", 0Dh, 0Ah
				BYTE	" + Each entry must fit a 32-bit register.", 0Dh, 0Ah
				BYTE	" + Afterwards, a list of the numbers will be displayed.", 0Dh, 0Ah
				BYTE	" + Next, their sum and average will be displayed.", 0
	askNum		BYTE	" Please enter a 'signed' decimal integers: ", 0
	error		BYTE	" Error: your input was not a signed integer, or it is out of range.", 0Dh, 0Ah
	tryAgain	BYTE	" Please try again: ", 0
	showList	BYTE	" Numbers that were accepted: ", 0
	showSum		BYTE	" The sum: ", 0
	showAverage	BYTE	" The average: ", 0
	showLine	BYTE	" -----------------------------------------------------", 0
	comma		BYTE	", ", 0
	minus		BYTE	"-", 0
	seeYou		BYTE	" Thanks for visiting! Come back again!", 0
	array		DWORD	ARRAYSIZE	DUP(?)	; array for storing the user's 10 numeric digits
	userStr		BYTE	HI			DUP(?)	; store the user's string digits
	outStr		BYTE	HI			DUP(?)	; temperary storage for str->numeric conversion & vice-versa
	inString	BYTE	HI			DUP(?)	; temperary storage for str->numeric conversion & vice-versa

.code
main PROC
	push	OFFSET	COLOR			; 8
	call	giveColor				; 4	

	push	OFFSET	showLine		; 16
	push	OFFSET	showInstr		; 12
	push	OFFSET	showTitle		; 8
	call	displayIntro			; 4

	push	OFFSET	array			; 36
	push	OFFSET	MAX				; 32
	push	OFFSET	MIN				; 28
	push	OFFSET	error			; 24
	push	OFFSET	ARRAYSIZE		; 20
	push	OFFSET	outStr			; 16
	push	OFFSET	askNum			; 12
	push	OFFSET	userStr			; 8
	call	generateArray			; 4

	push	OFFSET	minus			; 40
	push	OFFSET	MAX				; 36
	push	OFFSET	CONVERTER		; 32
	push	OFFSET	inString		; 28
	push	OFFSET	ARRAYSIZE		; 24
	push	OFFSET	Comma			; 20
	push	OFFSET	outStr			; 16
	push	OFFSET	showList		; 12
	push	OFFSET	array			; 8
	call	displayArray			; 4

	push	OFFSET	MIN				; 52
	push	OFFSET	showSum			; 48
	push	OFFSET	showAverage		; 44
	push	OFFSET	minus			; 40
	push	OFFSET	MAX				; 36
	push	OFFSET	CONVERTER		; 32
	push	OFFSET	inString		; 28
	push	OFFSET	ARRAYSIZE		; 24
	push	OFFSET	Comma			; 20
	push	OFFSET	outStr			; 16
	push	OFFSET	showList		; 12
	push	OFFSET	array			; 8
	call	displaySumAverage		; 4

	push	OFFSET	seeYou
	call	goodbyeMsg
	
	exit	
main ENDP

; ------------------------------------------------------------------------
; giveColor
; Description: changes the default foreground color from white to yellow.
;
; Preconditions: none
; Receives: global constant COLOR is received from the stack
; Returns: none
; Postconditions / Registers changed: foreground in the windows
; console is changed to a new color.
; ------------------------------------------------------------------------

giveColor	PROC
	push	ebp
	mov		ebp, esp

	mov		eax, [ebp+8]			; @COLOR for setting font color
	call	SetTextColor			

	pop		ebp
	ret		4
giveColor	ENDP

; ------------------------------------------------------------------------
; displayIntro
; Description: displays the program title, creator, program functionalities
; and the basic instructions to the user.		  
;
; Preconditions: none
; Receives: variables showLine, showInstr, showTitle are received from 
; the stack.
; Returns: none
; Postconditions / Registers changed: windows console will show the 
; specific messages to the user
; ------------------------------------------------------------------------

displayIntro	PROC
	push	ebp
	mov		ebp, esp
	
	call	CrLF
	call	CrLF
	displayString	showTitle		; show program's title
	call	CrLF
	displayString	showLine		; show series of dashes (cosmetic effect)
	call	CrLF
	displayString	showInstr		; show program's instructions
	call	CrLF
	displayString	showLine		; show series of dashes (cosmetic effect)

	call	CrLF
	call	CrLF

	pop		ebp
	ret		12
displayIntro	ENDP

; -----------------------------------------------------------------------------
; generateArray
; Description: gets 10 signed decimal integers from user and store in array	  
;
; Preconditions: each input (numeric) must fit in a 32-bit register
; Receives: variables array, error, outStr, askNum, and userStr from the stack
; Global constants MAX, MIN, and ARRAYSIZE also received from the stack
; Returns: array is filled with 10 signed decimal integers
; Postconditions / Registers changed: none
; -----------------------------------------------------------------------------

generateArray		PROC
	push	ebp
	mov		ebp, esp

	push	esi						; save registers that would be used
	push	ecx						; to the system stack
	push	eax	

	mov		esi, [ebp+36]			; esi now refers to @array
	mov		ecx, [ebp+20]			; set loop counter to @ARRAYSIZE(10), since we
									; want to ask for 10 valid inputs
top:								
	push	esi						; use to indicate and track the 
									; current element of array

	push	[ebp+36]				; @array
	push	[ebp+32]				; @MAX
	push	[ebp+28]				; @MIN
	push	[ebp+24]				; @error
	push	[ebp+20]				; @ARRAYSIZE
	push	[ebp+16]				; @outStr
	push	[ebp+12]				; @askNum
	push	[ebp+8]					; @userStr
	
	call	ReadVal
	
	add		esi, 4					; move to next index of array
	dec		ecx						; decrease loop counter ecx after each run
	mov		eax, 0					
	cmp		eax, ecx				; exit loop when ecx reach 0 (array has 10 elements)
	jne		top						; while ecx is not 0 yet, keep looping
bottom:
	
	pop		eax
	pop		ecx
	pop		esi

	pop		ebp
	ret		32						
generateArray		ENDP		

; ------------------------------------------------------------------------
; ReadVal
; Description: reads and converts a string of digits from user and 
; validates the input.
;
; Preconditions: none
; Receives: variables askNum, userStr, and error from the stack
; Global constants MAX, and ARRAYSIZE also from the stack
; 
; Returns: numeric form of the digit, converted from the string form
; Postconditions / Registers changed: none
; ------------------------------------------------------------------------

ReadVal		PROC
	push	ebp
	mov		ebp, esp
	pushad							; we're use all the general purpose registers
									; so saving all of them to the stack and restore at end
beginning:
	getString	askNum, userStr		; prompts user for an input & store results in userStr

	cld								
	mov		esi, [ebp+8]			; esi refers to @userStr
	mov		edi, [ebp+16]			; edi refers to @outStr
	mov		ecx, eax				; use string length (eax) from ReadString as loop counter
	mov		edx, eax				; create a copy of the loop counter
	mov		ebx, 0

findLetter:
	lodsb							; load the byte from the user's string
	cmp		ecx, edx				; check if current loop is first of the user string
	je		firstLoop				
	jmp		notfirstloop

firstLoop:
	; if it's the first loop of the whole string, check if
	; first char is 0-9,+, or - symbol. Otherwise char is invalid.
	
	cmp		eax, 57
	ja		foundError				; if hex is > 57, it's beyond 9, hence jump to error msg
	cmp		eax, 48
	jb		checkforSigns			; if hex < 48, jump to check for + - symbols

	mov		edx, 0					; if hex between 48-57, the char is 0-9
	push	edx				
	jmp		findNumeric				
	
checkforSigns:

	cmp		eax, 45
	je		isnegativesign			; if = 45, the char is - symbol
	cmp		eax, 43					; if = 43, the char is + symbol
	je		ispositivesign
	jmp		foundError				; if hex < 48, and not - or + smybol, then throw an error msg

isnegativesign:
	cmp		ecx, 1					; trigger error msg if user is attempting to 
	je		foundError				; entering - symbol only

	mov		edx, 100				; use 100 to 'mark' the string as negative
	push	edx						

	jmp		findNext

ispositivesign:
	cmp		ecx, 1					; trigger error msg if user is attempt to 
	je		foundError				; enter + symbol only

	mov		edx, 0					; use 0 to 'mark' the string as positive
	push	edx						
	jmp		findNext

notfirstloop:
	; if not first loop/first char, we don't have to check for possible +/-
	; symbol. hence only need check if char is 0-9
	cmp		eax, 48
	jb		foundError
	cmp		eax, 57
	ja		foundError
	
findNumeric:
	; numeric conversion of string values (based on Lecture 22's pseudocode algorithm)
	; but translated to assembly form
	mov		edx, [ebp+20]			; edx refers to @arraysize - constant 10

	add		eax, -48				; difference of current hex & -48 gives integer form

	push	eax						; save integer form (eax), and use eax for MUL

	mov		eax, ebx				; set eax = x, while ebx is the accumulator
	mul		edx						; multiple x (eax) with 10
	mov		ebx, eax				; return eax's value back to ebx
	pop		eax						; restore eax's value
	add		ebx, eax				; add 10 * x + (ascii - 48)

findNext:
	stosb							; store numeric form in output string
	loop	findLetter				; repeat until ecx (str length) reaches 0
	jmp		sizeCheck

foundError:

	displayString	error			; @error msg
	jmp		beginning				; ask user for # again

sizeCheck:
; Display the converted string:

	; edx = 100 indicates a negative str/digit
	; edx = 0 indicates a positive str/digit
	pop		edx

	cmp		edx, 100
	je		processNegatives
	
	mov		eax, [ebp+32]			; check if + numeric # fits as a 32-bit signed integer
	cmp		ebx, eax				; if char is > @MAX (2147483647) then it's invalid 
	ja		foundError
	jmp		bottom

processNegatives:
	; from here we know the # is some negative
	; next, check if it's 'smaller' than @MIN (2147483648)
	; if so, we neg to turn the # into negative, since it's positive form
	mov		eax, [ebp+28]			
	cmp		ebx, eax

	neg		ebx	
	ja		foundError
	jmp		bottom

bottom:
	call	crlf

	mov		edi, [ebp+40]			; edi refers to @esi (array's index)
	mov		[edi], ebx				; put the numeric number into this index

	popad							; restore all registers
	pop		ebp
	ret		36
ReadVal		ENDP

; ------------------------------------------------------------------------
; WriteVal
; Description: reads a numeric digit as input and outputs the digit in
; string form using the displayString macro.
;
; Preconditions: none
; Receives: variables outStr and inString received from the stack.
; The global constants ARRAYSIZE and CONVERTER are also from the stack.
; 
; Returns: the numeric digit is translated to its string form
; Postconditions / Registers changed: the string form of the digit is
; displayed to the user in the windows console.
; ------------------------------------------------------------------------

WriteVal	PROC
	push	ebp
	mov		ebp, esp

	pushad							; we're use all the general purpose registers
									; so saving all of them to the stack and pop later

	push	ecx

	mov		ebx, [ebp+24]			; ebx refers to @ARRAYSIZE (10)
	mov		edx, [ebp+32]			; edx refers to @CONVERT (4294967295)
	mov		eax, [esi]				


	cmp		eax, [ebp+12]			; check to see if current array element is negative or not
	jbe		notNegative
	
	mov		edx, 99					; '99' is used to 'mark' the # as positive
	push	edx						

	mov		ecx, [ebp+16]			; @outStr
	sub		ecx, eax
	mov		eax, ecx
	inc		eax
	mov		esi, eax				; save adjusted eax to esi
	mov		ecx, 0
	jmp		findLength


notNegative:
	mov		edx, 98					; '98' is used to 'mark' the # as negative
	push	edx
	mov		ecx, 0					; set length count to 0 
	mov		edi, 0

findLength:
	; calculate the length current #
	mov		edx, 0
	div		ebx

	inc		ecx						; for each DIV operation, +1 to ecx to indicate one digit exist in the #
	cmp		eax, 0
	jne		findLength				; while quotient is not 0 yet, keep DIV going & increasing ecx
	
	push	ecx						; save the generated str length (ecx) in the stack
	
	cmp		edi, 0

	mov		edi, [ebp+32]			; @CONVERTER

	jne		mini

	mov		eax, [esi]				
	jmp		top						

mini:
	mov		eax, esi				; if # was negative, restore the adjusted eax from the stack

top:					
	mov		edx, 0
	div		ebx
	push	eax						; save quotient to stack

	mov		eax, edx				; work with remainder
	add		eax, 48					; convert remainder to ascii form

	cld
	stosb							; move converted remainder to edi using stosb
	pop		eax	

	loop	top						; uses ecx from findLength as the loop counter
	
	pop		ecx						; restore the original string length from findLength & re-use for reverse string loop

	mov		esi, [ebp+32]			;@CONVERTER
	mov		edi, [ebp+20]			;@instring  (empty string)
	add		esi, ecx
	dec		esi
	
; ------------------------------BEGIN CITED CODE-------------------------------
; Source: the course's demo6.asm (DemoString)
; Function explanation: Since the string digit we generated is in 
; reverse representation, we want to load each byte into esi by reverse order, 
; thus we use 'std' (reverse direction) before using lodsb for loading. After
; the backend byte is loaded, we use cld (forward direction) to unload
; the byte into EDI. Repeating the process until all bytes are transferred
; and that gives the fully 'un-reversed' string. A slight modification is done
; to the demo code. In the demo's code didn't include a null terminating 0. 
; This works for the demo since it only need to reverse the whole string. 
; However, in this string it include numbers from the previous array element, 
; hence a 0 is added after the loop is complete, and is also unloaded to
; the outstring.

reverse:
	std
	lodsb
	cld
	stosb
	loop	reverse
	mov		eax, 0					
	stosb			
; -------------------------------END CITED CODE---------------------------------

bottom:
	pop		edx
	cmp		edx, 99
	je		addMinusSign			; add + or - ascii symbol to the str depending on
	cmp		edx, 98					; the 'mark' that was given for identification
	je		noMinusSign

addMinusSign:
	displayString minus

noMinusSign:
	pop		ecx
	displayString inString			; display the # in string form
	cmp		ecx, 1					; if only one loop count remaining, meaning 
	je		skipComma				; final array element, then don't add comma

	displayString comma				; display comma

skipComma:
	popad							; restoring all of the registers after
	pop		ebp						; finish using them in WriteVal
	ret		32
WriteVal	ENDP

; ---------------------------------------------------------------------------
; displayArray
; Description: uses the WriteVal subprocedure to convert each of array's
; numberic element into string form, then displays it to the windows console.
;
; Preconditions: array must be filled with 10 signed integers
; Receives: variables minus, inStr, comma, outStr, showList, and array 
; from the stack. Also, global constants MAX, CONVERTER, and ARRAYSIZE
; from the stack as well.
; 
; Returns: none
; Postconditions / Registers changed: the 10 numeric digits are displayed
; to the user as a list in the windows console.
; ---------------------------------------------------------------------------

displayArray	PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp+24]			; @ARRAYSIZE
	mov		esi, [ebp+8]			; @array

	push	eax
	push	ecx
	push	esi

	displayString	showList		; displays msg to windows console
top:
	push	esi						; ebp+40 in this case
	push	[ebp+16]				; @outStr
	push	[ebp+20]				; @comma
	push	[ebp+24]				; @ARRAYSIZE
	push	[ebp+28]				; @inString
	push	[ebp+32]				; @CONVERTER
	push	[ebp+36]				; @MAX
	push	[ebp+40]				; @minus

	call	WriteVal

	add		esi, 4					; move to next index in array
	
	dec		ecx						; decrease loop counter after each run
	mov		eax, 0					; reset eax for next run
	cmp		ecx, 0					; keep looping until all elements of array is printed
	je		bottom
	jne		top

	call	crlf
bottom:

	pop		esi
	pop		ecx
	pop		eax

	pop		ebp
	ret		36
displayArray		ENDP

; ----------------------------------------------------------------------------
; DisplaySumAverage
; Description: takes array and calculates the sum and rounded average, 
; then outputs the results to the window console using WriteVal subprocedure.
;
; Preconditions: none
; Receives: variables showSum, showAverage, minus, inString, comma, outStr,
; showList, and array from the stack. Also, global constants MIN, MAX,
; CONVERTER, and ARRAYSIZE from the stack.
; 
; Returns: none
; Postconditions / Registers changed: the suma and average are displayed to
; the user in the windows console.
; ----------------------------------------------------------------------------

DisplaySumAverage		PROC
	push	ebp
	mov		ebp, esp

	pushad							; all gen. registers used, hence push all

	mov		esi, [ebp+8]			; @array

; calculate & display the Sum
	mov		ecx, [ebp+24]			; @ARRAYSIZE
	mov		ebx, 0					; zero out ebx to use it as sum accumulator
top:
	mov		eax, [esi]				; eax refers to @array element
	add		ebx, eax				; add current array element to ebx (accumulator)
	add		esi, 4					; move to next array element
	loop	top

	call	crlf
	call	crlf
	displayString	showSum			; @showSum, displaying msg to windows console
	mov		eax, ebx

	mov		[esi], eax				; put sum into [esi], and
									; use WriteVal macro to display

	push	esi						; ebp+40 in this case
	push	[ebp+16]				; @outStr
	push	[ebp+20]				; @comma
	push	[ebp+24]				; @ARRAYSIZE
	push	[ebp+28]				; @inString
	push	[ebp+32]				; @CONVERTER
	push	[ebp+36]				; @MAX
	push	[ebp+40]				; @minus

	call	WriteVal
	call	crlf
	call	crlf

; calculate & display the Average
	cmp		eax, [ebp+52]			; check to see if sum is positive @MIN
	jb		positives		

negatives:
	mov		ecx, [ebp+24]			; ecx refers to @ARRAYSIZE (10)
	mov		ebx, 0
	mov		ebx, [ebp+32]			; @CONVERTER
	sub		ebx, eax				; 4294967295 - current value to turn back to positive
	mov		eax, ebx				; (if we kept the negative # in 429xxxxxxx and DIV,
	mov		edx, 0					; we'll end with up one digit less. hence we can treat
									; the # as positive first, and then revert back using neg
	div		ecx						
	neg		eax

	jmp		showResults

positives:
	mov		ecx, [ebp+24]			; @arraysize (10)
	mov		edx, 0					; empty edx for the remainder
	div		ecx

showResults:
	displayString	showAverage		; converts the numeric form of sum & average to string form
	mov		[esi], eax				; in each case, sum or average, both results use eax for storage

	push	esi
	push	[ebp+16]
	push	[ebp+20]
	push	[ebp+24]				; items pushed here are exactly the same as the previous
	push	[ebp+28]				; WriteVal call
	push	[ebp+32]				
	push	[ebp+36]
	push	[ebp+40]

	call	WriteVal
	call	crlf

	popad

	pop		ebp
	ret		48
DisplaySumAverage		ENDP

; -------------------------------------------------------------------
; GoodbyeMsg
; Description: displays a goodbye message to the user using the 
; displayString macro.
;
; Preconditions: none
; Receives: variable SeeYou from the stack
; 
; Returns: none
; Postconditions / Registers changed: the seeYou string is displayed
; to the windows console.
; -------------------------------------------------------------------

goodbyeMsg		PROC
	push	ebp
	mov		ebp, esp

	push	edx

	call	crlf
	displayString	seeYou			; macro to show the goodbye msg
	call	crlf

	pop		edx
	pop		ebp
	ret		4

goodbyeMsg		ENDP

END main
