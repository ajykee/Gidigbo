# Gidigbo Smart Contract

A blockchain-based implementation of Gidigbo, a traditional Nigerian wrestling game, built using Clarity smart contracts for the Stacks blockchain.

## Overview

Gidigbo is a traditional wrestling game where players compete in one-on-one matches, testing their strength, agility, and tactical skills. This smart contract implementation brings this cultural sport to the blockchain, allowing players to create characters, battle opponents, and level up their wrestlers.

## Features

- **Character Creation**: Create unique wrestlers with initial attributes
- **Battle System**: Engage in one-on-one battles with other wrestlers
- **Experience & Leveling**: Gain experience from battles and level up your character
- **Stats Management**: Manage character attributes like strength and agility
- **Battle History**: Track wins, losses, and battle timestamps
- **Administrative Controls**: Game pause/resume functionality for maintenance

## Smart Contract Functions

### Read-Only Functions

1. `get-character (character-id uint)`
   - Retrieves complete character information
   - Returns character details or none if not found

2. `get-character-stats (character-id uint)`
   - Retrieves character statistics
   - Returns level, experience, strength, agility, wins, and losses

### Public Functions

1. `create-character (name (string-ascii 24))`
   - Creates a new character with initial stats
   - Returns the new character ID
   - Only contract owner can create characters

2. `level-up (character-id uint)`
   - Increases character level if enough experience is accumulated
   - Enhances strength (+5) and agility (+3)
   - Requires sufficient experience points (level * 100)

3. `battle (attacker-id uint) (defender-id uint)`
   - Initiates a battle between two characters
   - Updates experience, wins, and losses for both participants
   - Includes cooldown period between battles
   - Returns battle outcome (true if attacker wins)

### Administrative Functions

1. `pause-game ()`
   - Pauses game operations
   - Only callable by contract owner

2. `resume-game ()`
   - Resumes game operations
   - Only callable by contract owner

## Error Codes

- `ERR_NOT_AUTHORIZED (u100)`: Unauthorized access attempt
- `ERR_CHARACTER_EXISTS (u101)`: Character ID already exists
- `ERR_CHARACTER_NOT_FOUND (u102)`: Character not found
- `ERR_INSUFFICIENT_LEVEL (u103)`: Insufficient experience for level up
- `ERR_COOLDOWN_ACTIVE (u104)`: Battle cooldown period still active

## Game Mechanics

### Character Attributes
- **Level**: Determines character progression
- **Experience**: Gained from battles, required for leveling up
- **Strength**: Contributes to battle power
- **Agility**: Contributes to battle power
- **Battle History**: Tracks wins and losses

### Battle System
- Battle power = Strength + Agility
- Winner determined by higher battle power
- Experience rewards:
  - Winner: 50 experience points
  - Loser: 20 experience points
- Cooldown period: 10 blocks between battles

## Development

### Prerequisites
- Clarity CLI
- Stacks blockchain development environment
- Clarinet for testing

### Testing
Use Clarinet to run contract tests:
```bash
clarinet test
```

### Deployment
Deploy using Clarinet or Stacks CLI:
```bash
clarinet deploy
```

## Security Considerations

- Only contract owner can create characters
- Cooldown period prevents battle spam
- Administrative controls for emergency situations
- Character ownership verification for actions

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request