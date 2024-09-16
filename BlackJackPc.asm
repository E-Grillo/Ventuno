#blackjack
#il programma permette di giocare contro il computer a un game di blackjack.
#all'inizio della partita vengono pescate 2 carte per giocatore
#ad ogni turno ogni giocatore sceglie se pescare un'altra carta o fermarsi al valore attuale
#l'obiettivo è arrivare a 21, se si eccede il valore si perde il game
#il computer deve arrivare almeno a 17 per vincere e parte sempre secondo
#viene simulato un mazzo di 52 carte e gli assi possono valere 11 o 1


.data
prompt_user:    .asciiz "\nDo vuoi pescare o fermarti? (1 = draw, 2 = stand): "
user_win:       .asciiz "\nHai vinto!\n"
comp_win:       .asciiz "\nHai perso!\n"
draw:           .asciiz "\nPareggio!\n"
your_hand:      .asciiz "\nLa tua mano: "
comp_hand:      .asciiz "\nLa mano del computer: "
first_draw:     .asciiz "\nPrima carta pescata; "
pc_strategy:    .asciiz "\nIl computer sta pescando...\n"

deck: #mazzo di 52 carte (figure = 10, asso = 11)
.word 2,3,4,5,6,7,8,9,10,10,10,10,11,
      2,3,4,5,6,7,8,9,10,10,10,10,11,
      2,3,4,5,6,7,8,9,10,10,10,10,11,
      2,3,4,5,6,7,8,9,10,10,10,10,11

.text
.globl main
# Funzione: main
main:
	li $t0, 0        # totale mano del giocatore
	li $t1, 0        # totale mano del computer
	li $t2, 0        # numero di assi nella mano del giocatore
	li $t3, 0        # numero di assi nella mano del computer
    
	# Pesca le carte iniziali per giocatore e computer
	jal draw_card    # Prima carta del giocatore
	add $t0, $t0, $v0
	bne $v0, 11, second_draw
	jal inc_player_ace
				
	second_draw:	
	# Stampa la mano del giocatore
	la $a0, first_draw
	li $v0, 4
	syscall
    
	li $v0, 1          # Stampa intero
	move $a0, $t0      # Totale della mano del giocatore
	syscall
	
	jal draw_card    # Seconda carta del giocatore
	add $t0, $t0, $v0
	bne $v0, 11, first_draw_pc
	jal inc_player_ace
    
	first_draw_pc:
	jal draw_card    # Prima carta del computer
	add $t1, $t1, $v0
	bne $v0, 11, second_draw_pc
	jal inc_computer_ace
	
	second_draw_pc:		
	jal draw_card    # Seconda carta del computer
	add $t1, $t1, $v0
	bne $v0, 11, player_turn
	jal inc_computer_ace

player_turn:

	beq $t0, 21, computer_turn_pre

	# Aggiusta il valore degli assi se necessario
	jal adjust_aces
    
	# Stampa la mano del giocatore
	la $a0, your_hand
	li $v0, 4
	syscall
    
	li $v0, 1          # Stampa intero
	move $a0, $t0      # Totale della mano del giocatore
	syscall

prompt:
# Chiede se il giocatore vuole pescare o fermarsi

	la $a0, prompt_user
	li $v0, 4
	syscall
    
	li $v0, 5          # Leggi l'input dell'utente
	syscall
	move $t4, $v0      # Memorizza la scelta dell'utente in $t4
    
	# Se l'utente sceglie di pescare
	li $t5, 1
	beq $t4, $t5, hit_user
    
	# Se l'utente sceglie di fermarsi, passa al turno del computer
	li $t5, 2
	beq $t4, $t5, computer_turn_pre

	j prompt

hit_user:
# Pesca un'altra carta

	jal draw_card
	add $t0, $t0, $v0
	bne $v0, 11, afterhit
	jal  inc_player_ace

	afterhit:
	# Aggiusta il valore degli assi se necessario
	jal adjust_aces
    
	# Controlla se il giocatore ha sballato
	li $t6, 21
	bgt $t0, $t6, computer_turn_pre # Se la mano del giocatore > 21, fine del gioco

	# Continua il turno del giocatore
	j player_turn

computer_turn_pre:

	# Stampa la mano del giocatore
	la $a0, your_hand
	li $v0, 4
	syscall
    
	li $v0, 1          # Stampa intero
	move $a0, $t0      # Totale della mano del giocatore
	syscall

computer_turn:

	# Aggiusta il valore degli assi se necessario
	jal adjust_aces

	# Stampa la mano del computer
	la $a0, comp_hand
	li $v0, 4
	syscall
    
	li $v0, 1          # Stampa intero
	move $a0, $t1      # Totale della mano del computer
	syscall
    
	# Strategia del computer: pesca fino a quando la mano >= 17
	li $t9, 21
	bne $t0, $t9, hand_check
	li $t7 , 21
	j endc
	
	hand_check:
	li $t7, 17
	bgt $t0, $t9, endc
	blt $t0, $t7, endc
	move $t7, $t0
	endc:
	bge $t1, $t7, end_game  # Se la mano del computer >= 17, fine del gioco
    
	# Il computer pesca
	la $a0, pc_strategy
	li $v0, 4
	syscall
    
	jal draw_card
	add $t1, $t1, $v0
	bne $v0, 11, afterPCHit
	jal inc_computer_ace
    
	afterPCHit:
	# Aggiusta il valore degli assi se necessario
	jal adjust_aces
    
	# Continua il turno del computer
	j computer_turn

end_game:

	# Aggiusta i valori delle mani di giocatore e computer
	jal adjust_aces
    
	# Stampa le mani finali di giocatore e computer
	la $a0, your_hand
	li $v0, 4
	syscall
	li $v0, 1
	move $a0, $t0
	syscall

	la $a0, comp_hand
	li $v0, 4
	syscall
	li $v0, 1
	move $a0, $t1
	syscall

	# Determina il vincitore
	li $t6, 21

	# Se il giocatore ha sballato
	bgt $t0, $t6, comp_wcheck

	# Se il computer ha sballato
	bgt $t1, $t6, user_wins

	# Se il giocatore ha una mano più alta del computer
	bgt $t0, $t1, user_wins

	# Se il computer ha una mano più alta del giocatore
	bgt $t1, $t0, comp_wins

	# Se entrambi hanno la stessa mano, è un pareggio
	j draw_game
    
    	# se il giocatore ha sballato il computer vince se non sballa
	comp_wcheck:
	bgt $t1, $t6, draw_game
	j comp_wins

	user_wins:
	la $a0, user_win
	li $v0, 4
	syscall
	j game_exit

	comp_wins:
	la $a0, comp_win
	li $v0, 4
	syscall
	j game_exit

	draw_game:
	la $a0, draw
	li $v0, 4
	syscall

	game_exit:
	li $v0, 10         # Uscita dal programma
	syscall

# Funzione: draw_card
# Genera casualmente un valore di carta tra 2 e 11 (per rappresentare da 2 ad Asso).
draw_card:

	move $a0, $zero
	li $v0, 42         # Imposta la generazione di numeri casuali
	li $a1, 52         # Genera un numero casuale tra 0 e 52
	syscall
	la $t4, deck
	sll $a0, $a0, 2    # moltilpico per 4 perché devo sommare a un indirizzo
	add $t4, $t4, $a0
	lw $v0, 0($t4)
	beq $v0, 0, draw_card
	li $t8, 0
	sw $t8, 0($t4)
	jr $ra             # Ritorna al chiamante

		
# Funzione: incrementa il conteggio degli assi del giocatore
inc_player_ace:
	addi $t2, $t2, 1
	jr $ra

# Funzione: incrementa il conteggio degli assi del computer
inc_computer_ace:
	addi $t3, $t3, 1
	jr $ra

# Funzione: adjust_aces
# Aggiusta il valore degli assi da 11 a 1 se la mano supera 21
adjust_aces:
	li $t4, 21        # Valore massimo consentito
	ble $t0, $t4, adjust_computer_aces # Se il totale del giocatore <= 21, aggiusta gli assi del computer
	blez $t2, adjust_computer_aces # Se non ci sono assi, salta l'aggiustamento
	
# Riduci il valore della mano di 10 per ogni asso e decrementa il conteggio degli assi
adjust_player_aces:
	ble $t0, $t4, adjust_computer_aces # Se la mano <= 21, finisci
	li $t6, 10        # Valore da sottrarre per ogni aggiustamento di asso
	sub $t0, $t0, $t6
	subi $t2, $t2, 1
	bgtz $t2, adjust_player_aces # Continua ad aggiustare se ci sono più assi

adjust_computer_aces:
	ble $t1, $t4, end_adjust # Se il totale del computer <= 21, fine dell'aggiustamento
	blez $t3, end_adjust # Se non ci sono assi, salta l'aggiustamento
	
# Riduci il valore della mano di 10 per ogni asso e decrementa il conteggio degli assi
adjust_computer_aces_loop:
	ble $t1, $t4, end_adjust # Se la mano <= 21, finisci
	li $t6, 10        # Valore da sottrarre per ogni aggiustamento di asso
	sub $t1, $t1, $t6
	subi $t3, $t3, 1
	bgtz $t3, adjust_computer_aces_loop # Continua ad aggiustare se ci sono più assi

end_adjust:
jr $ra            # Ritorna al chiamante
