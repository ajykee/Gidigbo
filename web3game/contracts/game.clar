;; Gidigbo - A blockchain-based Nigerian wrestling game
;; Version: 1.0.0

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_CHARACTER_EXISTS (err u101))
(define-constant ERR_CHARACTER_NOT_FOUND (err u102))
(define-constant ERR_INSUFFICIENT_LEVEL (err u103))
(define-constant ERR_COOLDOWN_ACTIVE (err u104))

;; Data Variables
(define-data-var last-character-id uint u0)
(define-data-var game-paused bool false)

;; Character Data Maps
(define-map characters
    { character-id: uint }
    {
        owner: principal,
        name: (string-ascii 24),
        level: uint,
        experience: uint,
        strength: uint,
        agility: uint,
        last-battle: uint,
        wins: uint,
        losses: uint
    }
)

;; Battle Results Map
(define-map battle-history
    { battle-id: uint }
    {
        winner: uint,
        loser: uint,
        timestamp: uint
    }
)

;; Read-Only Functions

(define-read-only (get-character (character-id uint))
    (map-get? characters { character-id: character-id })
)


;; Public Functions

(define-public (create-character (name (string-ascii 24)))
    (let
        (
            (new-id (+ (var-get last-character-id) u1))
        )
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (is-none (map-get? characters { character-id: new-id })) ERR_CHARACTER_EXISTS)
        
        (map-set characters
            { character-id: new-id }
            {
                owner: tx-sender,
                name: name,
                level: u1,
                experience: u0,
                strength: u10,
                agility: u10,
                last-battle: u0,
                wins: u0,
                losses: u0
            }
        )
        
        (var-set last-character-id new-id)
        (ok new-id)
    )
)

(define-public (level-up (character-id uint))
    (let
        (
            (character (unwrap! (map-get? characters { character-id: character-id }) ERR_CHARACTER_NOT_FOUND))
            (current-level (get level character))
            (current-exp (get experience character))
            (exp-needed (* current-level u100))
        )
        (asserts! (is-eq (get owner character) tx-sender) ERR_NOT_AUTHORIZED)
        (asserts! (>= current-exp exp-needed) ERR_INSUFFICIENT_LEVEL)
        
        (map-set characters
            { character-id: character-id }
            (merge character {
                level: (+ current-level u1),
                experience: (- current-exp exp-needed),
                strength: (+ (get strength character) u5),
                agility: (+ (get agility character) u3)
            })
        )
        (ok true)
    )
)

(define-public (battle (attacker-id uint) (defender-id uint))
    (let
        (
            (attacker (unwrap! (map-get? characters { character-id: attacker-id }) ERR_CHARACTER_NOT_FOUND))
            (defender (unwrap! (map-get? characters { character-id: defender-id }) ERR_CHARACTER_NOT_FOUND))
            (current-block-height block-height)
            (cooldown-blocks u10)
        )
        (asserts! (is-eq (get owner attacker) tx-sender) ERR_NOT_AUTHORIZED)
        (asserts! (> current-block-height (+ (get last-battle attacker) cooldown-blocks)) ERR_COOLDOWN_ACTIVE)
        
        (let
            (
                (attacker-power (+ (get strength attacker) (get agility attacker)))
                (defender-power (+ (get strength defender) (get agility defender)))
                (attacker-wins (> attacker-power defender-power))
            )
            
            ;; Update attacker stats
            (map-set characters
                { character-id: attacker-id }
                (merge attacker {
                    last-battle: current-block-height,
                    experience: (+ (get experience attacker) (if attacker-wins u50 u20)),
                    wins: (+ (get wins attacker) (if attacker-wins u1 u0)),
                    losses: (+ (get losses attacker) (if attacker-wins u0 u1))
                })
            )
            
            ;; Update defender stats
            (map-set characters
                { character-id: defender-id }
                (merge defender {
                    experience: (+ (get experience defender) (if attacker-wins u20 u50)),
                    wins: (+ (get wins defender) (if attacker-wins u0 u1)),
                    losses: (+ (get losses defender) (if attacker-wins u1 u0))
                })
            )
            
            (ok attacker-wins)
        )
    )
)

;; Administrative Functions

(define-public (pause-game)
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (var-set game-paused true)
        (ok true)
    )
)

(define-public (resume-game)
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (var-set game-paused false)
        (ok true)
    )
)