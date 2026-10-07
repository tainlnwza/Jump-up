# Domain Vocabulary - Gamified Fitness Application

## Core Concepts

### Boss Battle
A quick-time event (QTE) combat session where the user performs exercise poses in response to prompts to defeat a virtual boss character. Each pose functions as an attack or defense ability consuming mana. Victory grants exp, coins, and achievements.

### Exercise Pose
A specific body movement tracked by MediaPipe. The application recognizes exactly 5 poses in game mode:
- **Punch**: Basic attack dealing normal damage
- **Uppercut**: Critical attack dealing higher damage  
- **Squat**: Dodge maneuver to avoid boss attacks
- **Plank**: Shield defense to block incoming damage
- **High Knee**: Mana regeneration ability

### Mana
An in-game resource consumed when performing exercise poses during boss battles. Regenerates through the High Knee pose. Prevents spamming of high-damage moves and encourages pose variety.

### Expert Program
A workout routine created and shared by fitness experts or experienced users in the Community. Consists of exercise sequences with timing, repetitions, and instructional content (video, images, text). Users can follow one Expert Program at a time.

### Personalized Build
An AI-customized version of an Expert Program tailored to an individual user based on their onboarding data (fitness goals, body shape, physical limitations, available equipment, preferred time). Generated after the user selects a program from the Community.

### Daily Streak
Consecutive days the user has logged into the application. Displayed prominently on the home page as a gamification mechanic to encourage regular engagement.

### Quest
A challenge or objective the user can complete to earn rewards (exp, coins, achievements). Displayed as "today quest" on the home page.

### Level
A progression metric representing the user's overall advancement in the app. Increases as the user accumulates exp from completing workouts and boss battles.

### Achievement
A badge or unlock earned by completing specific milestones or challenges. Displayed on the Results page and stored in the user's achievement collection.

### Community
A shared space within the app where users and experts post their workout programs. Programs can be browsed, followed, and used as the basis for personalized builds. Does not require approval before posting.

### Results Page
A summary screen displayed after completing a boss battle or workout session. Shows exp earned, coins earned, achievements unlocked, and level progression.

## Workflow Terms

### Onboarding Flow
The initial setup sequence where new users provide personal data:
1. Fitness goal selection
2. Personal information (age, weight, height)
3. Available equipment selection
4. Preferred workout time
5. Body shape selection
6. Physical limitations/restrictions

This data is used by AI to generate personalized builds.

### AI Analysis
The process where an AI service evaluates user onboarding data and Expert Programs to generate appropriate workout parameters (duration, repetition count, rest periods) customized for the individual user.

### MediaPipe Integration
Real-time body pose detection used to track exercise form during both game mode and workout mode. Validates that the user is correctly performing the required poses.

## UI Components

### Hamburger Menu
A three-line icon in the top-left corner providing access to:
- Settings
- App information
- Terms of use
- About/Credits
- Contact support

### Bottom Navigation Bar
Primary navigation with 5 tabs:
- Home
- Plan (workout schedule/planning)
- Shop (cosmetic items for profile/mascot)
- Progress (statistics and history)
- Profile (user account details)

### Notifications
In-app notification system (top-right corner) showing alerts, achievement unlocks, and system messages.

## Monetization Terms

### Coin
In-app currency earned through gameplay and workouts. Used in the Shop to purchase cosmetic items.

### Shop
A marketplace where users spend coins to buy decorative items for their profile or mascot. Uses only in-app currency, not real money.

### Cosmetic Item
Visual customization options (profile decorations, mascot appearances) that do not affect gameplay or workout effectiveness. Purchased with coins in the Shop.
