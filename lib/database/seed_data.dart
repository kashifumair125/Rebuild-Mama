import 'package:drift/drift.dart';
import 'app_database.dart';
import 'sos_seed_data.dart';

/// Seed data for workouts and exercises
/// This file contains all exercise data for the 3-level workout system
class WorkoutSeedData {
  static Future<void> seedDatabase(AppDatabase db, int userId) async {
    // Clear existing workout data for this user
    await db.workoutDao.deleteWorkoutsByUserId(userId);

    // Seed Level 1: Repair (0-6 weeks)
    await _seedLevel1(db, userId);

    // Seed Level 2: Rebuild (6-12 weeks)
    await _seedLevel2(db, userId);

    // Seed Level 3: Strengthen (12+ weeks)
    await _seedLevel3(db, userId);

    // Seed SOS routines (independent of user)
    await SosSeedData.seedSosData(db);
  }

  /// Level 1: Repair (0-6 weeks) - 5 exercises, 11 min total
  /// Goal: Gentle reconnection with core
  static Future<void> _seedLevel1(AppDatabase db, int userId) async {
    final workoutId = await db.workoutDao.insertWorkout(
      WorkoutsCompanion(
        userId: Value(userId),
        level: const Value(1),
        name: const Value('Level 1: Repair'),
        description: const Value(
          'Gentle exercises focused on healing and early recovery. Perfect for 0-6 weeks postpartum. Goal: Gentle reconnection with core.',
        ),
        durationMinutes: const Value(11),
        isCompleted: const Value(false),
      ),
    );

    final exercises = [
      // Exercise 1: Diaphragmatic Breathing
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Diaphragmatic Breathing'),
        description: const Value(
          '''STARTING POSITION:
• Lie on back with knees bent, feet flat on floor hip-width apart
• One hand on chest, one hand on belly
• Head supported by pillow (optional for comfort)
• Neutral spine with natural curve in lower back

STEP-BY-STEP EXECUTION:

1. INHALE (4 seconds):
   - Breathe in slowly through NOSE
   - Feel belly RISE and EXPAND like a balloon
   - Hand on belly should lift UP
   - Chest stays relatively STILL
   - Pelvic floor muscles gently RELAX and "open"

2. EXHALE (6 seconds):
   - Breathe out slowly through MOUTH (pursed lips)
   - Feel belly DEFLATE and FLATTEN
   - Hand on belly lowers DOWN
   - Gently engage pelvic floor (like stopping urine flow)
   - Belly button draws IN toward spine

3. PAUSE (2 seconds):
   - Brief rest before next breath
   - Complete relaxation

BREATHING PATTERN:
Inhale 4 seconds → Exhale 6 seconds → Pause 2 seconds

KEY POINTS:
• This is FOUNDATION for all other exercises
• Can be done immediately after birth (even day 1)
• Practice 3-5 times daily
• Sets foundation for pelvic floor connection

SAFETY NOTES:
• Never hold breath
• Don't force belly movement
• Stop if dizzy (breathing too fast)''',
        ),
        animationPath: const Value('assets/animations/level1/breathing.json'),
        setsReps: const Value('10-15 breaths'),
        durationSeconds: const Value(120),
        orderIndex: const Value(1),
      ),

      // Exercise 2: Pelvic Floor Activation (Kegels)
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Pelvic Floor Activation'),
        description: const Value(
          '''STARTING POSITION:
• Sit comfortably on chair or lie on back
• Feet flat on floor
• Spine neutral, shoulders relaxed

STEP-BY-STEP EXECUTION:

Phase 1: SLOW HOLDS (10 reps)

1. INHALE (prepare):
   - Deep breath through nose
   - Pelvic floor RELAXES completely

2. EXHALE + CONTRACT (5-10 seconds):
   - Imagine stopping urine mid-flow
   - Squeeze and LIFT pelvic floor muscles UP toward head
   - Feel like you're drawing vagina UP into body
   - OR imagine stopping gas from passing
   - Maintain normal breathing (don't hold breath!)

3. RELEASE (5 seconds):
   - Completely RELAX pelvic floor
   - Feel muscles "drop" down
   - Relaxation is as important as contraction

Phase 2: QUICK PULSES (10 reps)
1. Quick squeeze (1 second)
2. Quick release (1 second)
3. Repeat rapidly like "fluttering"

Phase 3: COUGH/SNEEZE PREP (3 reps)
1. Engage pelvic floor
2. Cough or clear throat while HOLDING contraction
3. Release

BREATHING PATTERN:
Inhale to prepare → Exhale during squeeze → Normal breathing while holding

KEY POINTS:
• Should feel INTERNAL lifting sensation
• No visible external movement
• Relaxation between reps is ESSENTIAL
• Do NOT squeeze glutes, thighs, or hold breath

SAFETY NOTES:
• Stop if pain or heaviness increases
• Never bear down or push OUT
• If unsure you're doing it correctly, see pelvic floor PT''',
        ),
        animationPath: const Value('assets/animations/level1/kegels.json'),
        setsReps: const Value('10 slow + 10 pulses + 3 cough prep'),
        durationSeconds: const Value(180),
        orderIndex: const Value(2),
      ),

      // Exercise 3: Pelvic Tilts
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Pelvic Tilts'),
        description: const Value(
          '''STARTING POSITION:
• Lie on back
• Knees bent, feet flat on floor hip-width apart
• Arms relaxed at sides
• Neutral spine

STEP-BY-STEP EXECUTION:

1. POSTERIOR TILT (exhale):
   - Exhale through mouth
   - Press lower back FLAT against floor
   - Tailbone tucks UNDER slightly
   - Belly button draws IN toward spine
   - Pelvis rotates UP (pubic bone tilts up)
   - Hold 3 seconds

2. RETURN TO NEUTRAL (inhale):
   - Inhale through nose
   - Gently release
   - Return to natural curve in lower back
   - Pelvis returns to neutral

3. REPEAT slowly and controlled

BREATHING PATTERN:
Inhale (neutral) → Exhale (flatten back) → Hold 3s → Inhale (release)

KEY POINTS:
• Movement comes from PELVIS, not pushing through feet
• Gentle core engagement
• Avoid squeezing glutes
• Small, controlled movement (not exaggerated)

SAFETY NOTES:
• Safe for diastasis recti
• Stop if back pain occurs
• Do not arch back (skip anterior tilt if you have diastasis recti)''',
        ),
        animationPath: const Value('assets/animations/level1/pelvic_tilts.json'),
        setsReps: const Value('10 reps'),
        durationSeconds: const Value(120),
        orderIndex: const Value(3),
      ),

      // Exercise 4: Cat-Cow Stretch
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Cat-Cow Stretch'),
        description: const Value(
          '''STARTING POSITION:
• All fours (hands and knees)
• Hands directly under shoulders
• Knees directly under hips
• Neutral spine (flat back)
• Head in line with spine

STEP-BY-STEP EXECUTION:

1. CAT POSE (exhale):
   - Exhale through mouth
   - Round spine UP toward ceiling (like scared cat)
   - Tuck chin to chest
   - Tailbone tucks UNDER
   - Belly button draws IN toward spine
   - Hold 3 seconds

2. COW POSE (inhale) - MODIFIED for postpartum:
   - Inhale through nose
   - Return to NEUTRAL spine only (flat back)
   - DO NOT arch back excessively
   - Keep core gently engaged
   - Head returns to neutral

3. REPEAT smooth, flowing motion

BREATHING PATTERN:
Inhale (neutral) → Exhale (cat pose) → Hold 3s → Inhale (return)

KEY POINTS:
• MODIFIED version: Do NOT arch back (skip cow arch)
• Movement initiates from pelvis/tailbone
• Shoulders stay relaxed
• Wrists stay aligned under shoulders

SAFETY NOTES:
• DO NOT arch back if you have diastasis recti
• Stop if wrist pain (use fists instead of flat palms)
• Stop if back pain''',
        ),
        animationPath: const Value('assets/animations/level1/cat_cow.json'),
        setsReps: const Value('10 reps'),
        durationSeconds: const Value(120),
        orderIndex: const Value(4),
      ),

      // Exercise 5: Heel Slides
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Heel Slides'),
        description: const Value(
          '''STARTING POSITION:
• Lie on back
• Both knees bent, feet flat on floor
• Arms at sides
• Neutral spine

STEP-BY-STEP EXECUTION:

1. ENGAGE CORE:
   - Belly button draws gently IN
   - Pelvic floor lightly engaged
   - Lower back maintains contact with floor

2. SLIDE HEEL OUT (exhale):
   - Exhale through mouth
   - Slowly slide ONE heel away from body
   - Straighten leg along floor
   - Keep lower back FLAT on floor
   - If back arches, stop there (don't extend fully)
   - Hold 2 seconds

3. SLIDE HEEL BACK (inhale):
   - Inhale through nose
   - Slowly slide heel back to starting position
   - Maintain core engagement throughout

4. SWITCH LEGS

BREATHING PATTERN:
Inhale (prepare) → Exhale (slide out) → Inhale (slide back)

KEY POINTS:
• Core stays engaged ENTIRE time
• Lower back must NOT arch off floor
• Move slowly and controlled
• Range of motion varies (that's OK!)

SAFETY NOTES:
• Stop sliding when back starts to arch
• Safe for diastasis recti
• Do not force full extension''',
        ),
        animationPath: const Value('assets/animations/level1/heel_slides.json'),
        setsReps: const Value('10 reps each leg'),
        durationSeconds: const Value(120),
        orderIndex: const Value(5),
      ),
    ];

    await db.exerciseDao.insertMultipleExercises(exercises);
  }

  /// Level 2: Rebuild (6-12 weeks) - 5 exercises, 15 min total
  /// Goal: Progressive core & functional strength
  static Future<void> _seedLevel2(AppDatabase db, int userId) async {
    final workoutId = await db.workoutDao.insertWorkout(
      WorkoutsCompanion(
        userId: Value(userId),
        level: const Value(2),
        name: const Value('Level 2: Rebuild'),
        description: const Value(
          'Moderate exercises to rebuild core strength and stability. Suitable for 6-12 weeks postpartum. Goal: Progressive core & functional strength.',
        ),
        durationMinutes: const Value(15),
        isCompleted: const Value(false),
      ),
    );

    final exercises = [
      // Exercise 1: Glute Bridges
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Glute Bridges'),
        description: const Value(
          '''STARTING POSITION:
• Lie on back
• Knees bent, feet flat on floor hip-width apart
• Feet positioned close to glutes (heels 6-8 inches from butt)
• Arms at sides, palms down
• Neutral spine

STEP-BY-STEP EXECUTION:

1. PREPARE (inhale):
   - Take deep breath
   - Engage pelvic floor lightly
   - Engage core

2. LIFT HIPS (exhale):
   - Exhale through mouth
   - Press through HEELS (not toes)
   - Lift hips UP toward ceiling
   - Squeeze glutes at top
   - Body forms straight line: shoulders → hips → knees
   - Hold top position 2-3 seconds
   - Do NOT overarch lower back

3. LOWER (inhale):
   - Inhale through nose
   - Slowly lower hips back down
   - Control the descent (don't drop)
   - Tap floor lightly and repeat

PROGRESSION:
Week 1-2: Regular bridges (both feet down)
Week 3-4: Add 2-second hold at top
Week 5+: Single-leg bridge (one foot lifted)

BREATHING PATTERN:
Inhale (prepare) → Exhale (lift) → Hold 2s → Inhale (lower)

KEY POINTS:
• Drive through HEELS, not toes
• Glutes do the work, not lower back
• Maintain straight line (no sagging hips)
• Control both up and down phases

SAFETY NOTES:
• Do NOT overarch lower back at top
• Stop if lower back pain
• Keep knees tracking over toes (don't let them fall in)''',
        ),
        animationPath: const Value('assets/animations/level2/bridges.json'),
        setsReps: const Value('3 sets x 10 reps'),
        durationSeconds: const Value(120),
        orderIndex: const Value(1),
      ),

      // Exercise 2: Modified Planks (Knee Plank)
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Modified Planks'),
        description: const Value(
          '''STARTING POSITION:
• All fours (hands and knees)
• Hands directly under shoulders (or slightly forward)
• Walk knees back slightly
• Body forms straight line: head → shoulders → hips → knees

STEP-BY-STEP EXECUTION:

1. SET UP POSITION:
   - From all fours, walk knees BACK 6-12 inches
   - Hands remain under shoulders
   - Engage core (belly button IN)
   - Body weight shifts forward over hands

2. HOLD PLANK:
   - Maintain straight line from head to knees
   - Do NOT let hips sag down
   - Do NOT pike hips up
   - Engage glutes lightly
   - Breathe normally (don't hold breath!)
   - Hold 15-30 seconds

3. REST:
   - Lower down to all fours
   - Rest 30 seconds between sets

PROGRESSION:
Week 1-2: 3 x 15 seconds
Week 3-4: 3 x 30 seconds
Week 5+: Full plank (toes instead of knees)

BREATHING PATTERN:
Breathe normally throughout hold (4s in / 4s out)

KEY POINTS:
• Weight should be OVER hands, not at knees
• Core stays engaged entire time
• Neutral neck (look down, not forward)
• Knees are support, not weight-bearing

SAFETY NOTES:
• Stop if doming appears in belly (diastasis recti)
• Stop if lower back pain
• Do not progress to full plank until belly stays flat''',
        ),
        animationPath: const Value('assets/animations/level2/modified_planks.json'),
        setsReps: const Value('3 sets x 15-30 seconds'),
        durationSeconds: const Value(120),
        orderIndex: const Value(2),
      ),

      // Exercise 3: Bodyweight Squats
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Bodyweight Squats'),
        description: const Value(
          '''STARTING POSITION:
• Stand with feet hip-width to shoulder-width apart
• Toes pointed forward or slightly out (10-15 degrees)
• Arms in front for balance or at sides
• Chest up, shoulders back

STEP-BY-STEP EXECUTION:

1. PREPARE (inhale):
   - Deep breath through nose
   - Engage core
   - Engage pelvic floor

2. LOWER DOWN (continue inhaling):
   - Hinge at HIPS first (like sitting back in chair)
   - Bend knees, lowering body down
   - Knees track over toes (don't let them cave in)
   - Keep chest UP, back straight
   - Lower until thighs parallel to floor (or as low as comfortable)
   - Heels stay planted on floor
   - Knees should not go past toes excessively

3. STAND UP (exhale):
   - Exhale through mouth
   - Press through HEELS
   - Squeeze glutes at top
   - Imagine pushing floor away
   - Fully extend hips and knees at top

PROGRESSION:
Week 1-2: Chair squats (sit on chair, then stand)
Week 3-4: Air squats (full range)
Week 5+: Add light weight (hold baby or water bottle)

BREATHING PATTERN:
Inhale (lower down) → Exhale (stand up)

KEY POINTS:
• SIT BACK, don't just bend knees forward
• Chest stays UP (don't round back)
• Heels planted (don't rise onto toes)
• Knees track in line with toes

SAFETY NOTES:
• Use chair for support if needed
• Don't go below parallel if knee pain
• Stop if pelvic pressure or leaking occurs''',
        ),
        animationPath: const Value('assets/animations/level2/squats.json'),
        setsReps: const Value('3 sets x 12 reps'),
        durationSeconds: const Value(120),
        orderIndex: const Value(3),
      ),

      // Exercise 4: Bird Dog
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Bird Dog'),
        description: const Value(
          '''STARTING POSITION:
• All fours (hands and knees)
• Hands under shoulders, knees under hips
• Neutral spine (flat back)
• Core engaged

STEP-BY-STEP EXECUTION:

1. PREPARE:
   - Engage core (draw belly IN)
   - Keep spine neutral and still

2. EXTEND (exhale):
   - Exhale through mouth
   - Slowly extend RIGHT arm forward (thumb up)
   - Simultaneously extend LEFT leg back
   - Arm and leg parallel to floor
   - Body forms straight line: fingertips → head → hips → toes
   - Hold 3-5 seconds
   - Do NOT rotate hips or shoulders
   - Keep back flat (don't arch or sag)

3. RETURN (inhale):
   - Inhale through nose
   - Slowly return arm and leg to starting position
   - Tap down lightly

4. SWITCH SIDES:
   - Left arm + right leg

PROGRESSION:
Week 1-2: Arm only OR leg only
Week 3-4: Arm + leg together
Week 5+: Hold 10 seconds

BREATHING PATTERN:
Inhale (prepare) → Exhale (extend) → Hold → Inhale (return)

KEY POINTS:
• Minimize movement in spine (stay stable)
• Hips stay LEVEL (don't rotate)
• Slow, controlled movement
• Core engaged entire time

SAFETY NOTES:
• Stop if back pain
• Stop if wobbling excessively (regress to arm or leg only)''',
        ),
        animationPath: const Value('assets/animations/level2/bird_dog.json'),
        setsReps: const Value('10 reps each side'),
        durationSeconds: const Value(120),
        orderIndex: const Value(4),
      ),

      // Exercise 5: Wall Push-ups
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Wall Push-ups'),
        description: const Value(
          '''STARTING POSITION:
• Stand facing wall, arm's length away
• Place hands on wall at shoulder height
• Hands shoulder-width apart
• Feet hip-width apart
• Body forms slight angle to wall

STEP-BY-STEP EXECUTION:

1. PREPARE (inhale):
   - Engage core
   - Keep body in straight line

2. LOWER (continue inhaling):
   - Bend elbows
   - Lower chest toward wall
   - Elbows bend at 45-degree angle (not straight out)
   - Keep body straight (don't bend at hips)
   - Lower until nose almost touches wall

3. PUSH AWAY (exhale):
   - Exhale through mouth
   - Press through palms
   - Straighten arms
   - Return to starting position

PROGRESSION:
Week 1-2: Wall push-ups (vertical)
Week 3-4: Countertop push-ups (more horizontal)
Week 5+: Knee push-ups on floor

BREATHING PATTERN:
Inhale (lower to wall) → Exhale (push away)

KEY POINTS:
• Body stays in straight line
• Elbows tuck slightly (45 degrees)
• Control both lowering and pushing phases
• Full range of motion

SAFETY NOTES:
• Stop if shoulder pain
• Do not let elbows flare straight out to sides
• Keep core engaged to prevent back arching''',
        ),
        animationPath: const Value('assets/animations/level2/wall_pushups.json'),
        setsReps: const Value('3 sets x 10 reps'),
        durationSeconds: const Value(120),
        orderIndex: const Value(5),
      ),
    ];

    await db.exerciseDao.insertMultipleExercises(exercises);
  }

  /// Level 3: Strengthen (12+ weeks) - 5 exercises, 20 min total
  /// Goal: Full-body strength & athletic performance
  static Future<void> _seedLevel3(AppDatabase db, int userId) async {
    final workoutId = await db.workoutDao.insertWorkout(
      WorkoutsCompanion(
        userId: Value(userId),
        level: const Value(3),
        name: const Value('Level 3: Strengthen'),
        description: const Value(
          'Advanced exercises to build strength, endurance, and power. For 12+ weeks postpartum. Goal: Full-body strength & athletic performance.',
        ),
        durationMinutes: const Value(20),
        isCompleted: const Value(false),
      ),
    );

    final exercises = [
      // Exercise 1: Full Plank
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Full Plank'),
        description: const Value(
          '''STARTING POSITION:
• Face down on mat
• Forearms on ground, elbows under shoulders
• OR hands on ground (high plank variation)
• Toes tucked under

STEP-BY-STEP EXECUTION:

1. LIFT INTO PLANK:
   - Press up onto forearms/hands and toes
   - Body forms straight line: head → shoulders → hips → heels
   - Engage EVERYTHING:
     - Core pulled IN tight
     - Glutes squeezed
     - Quads engaged (legs straight)
     - Shoulders pulled back

2. HOLD:
   - Breathe normally (don't hold breath!)
   - Maintain perfect alignment
   - Eyes look down (neutral neck)
   - Hold 30-60 seconds

3. REST:
   - Lower down to knees
   - Rest 30-60 seconds

PROGRESSION:
Week 1-2: Forearm plank 30s
Week 3-4: Forearm plank 60s
Week 5+: High plank (on hands) or plank variations

BREATHING PATTERN:
Steady, rhythmic breathing: 4s in / 4s out

KEY POINTS:
• Perfect alignment is KEY
• Core drives stability, not shoulders
• Squeeze glutes to protect lower back
• Neutral neck (don't look forward)

SAFETY NOTES:
• Stop if belly domes or bulges (diastasis recti issue)
• Stop if lower back pain
• Do NOT progress past 60s (diminishing returns)''',
        ),
        animationPath: const Value('assets/animations/level3/full_planks.json'),
        setsReps: const Value('3 sets x 30-60 seconds'),
        durationSeconds: const Value(120),
        orderIndex: const Value(1),
      ),

      // Exercise 2: Lunges
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Lunges'),
        description: const Value(
          '''STARTING POSITION:
• Stand tall, feet hip-width apart
• Hands on hips or hanging at sides
• Chest up, shoulders back
• Core engaged

STEP-BY-STEP EXECUTION (Forward Lunge):

1. STEP FORWARD (inhale):
   - Take long step forward with right foot
   - Land heel first, then full foot
   - Keep torso upright (don't lean forward)

2. LOWER DOWN (continue inhaling):
   - Bend both knees simultaneously
   - Lower back knee toward floor
   - Front knee stays over ankle (not past toes)
   - Back heel lifts off ground
   - Lower until front thigh parallel to floor
   - Back knee hovers 1-2 inches off floor

3. PUSH BACK (exhale):
   - Press through front heel
   - Push back to starting position
   - Engage glutes and quads

4. ALTERNATE LEGS

ALTERNATIVE: Reverse Lunge (Easier)
- Step BACKWARD instead of forward
- Same mechanics
- Easier on knees

PROGRESSION:
Week 1-2: Stationary lunges (don't step, just lower)
Week 3-4: Walking lunges
Week 5+: Add light weights

BREATHING PATTERN:
Inhale (step and lower) → Exhale (push back)

KEY POINTS:
• Front knee tracks over ankle (not past toes)
• Torso stays UPRIGHT (don't lean forward)
• Back knee hovers, doesn't slam down
• Weight in front heel

SAFETY NOTES:
• Use wall for balance if needed
• Stop if knee pain
• Reverse lunges are easier on knees''',
        ),
        animationPath: const Value('assets/animations/level3/lunges.json'),
        setsReps: const Value('3 sets x 10 reps each leg'),
        durationSeconds: const Value(240),
        orderIndex: const Value(2),
      ),

      // Exercise 3: Mountain Climbers
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Mountain Climbers'),
        description: const Value(
          '''STARTING POSITION:
• High plank position
• Hands directly under shoulders
• Body in straight line
• Core engaged

STEP-BY-STEP EXECUTION:

1. START POSITION:
   - Begin in high plank (hands and toes)
   - Core tight, body straight

2. DRIVE KNEE IN (quick motion):
   - Drive RIGHT knee toward chest
   - Keep hips low (don't pike up)
   - Foot comes off ground
   - Tap toe near hands

3. SWITCH (quick):
   - Immediately switch legs
   - Drive LEFT knee to chest
   - Right leg extends back

4. CONTINUE ALTERNATING:
   - Quick, running motion
   - 20 seconds continuous

PROGRESSION:
Week 1-2: Slow mountain climbers (2s per leg)
Week 3-4: Moderate pace (1s per leg)
Week 5+: Fast pace (0.5s per leg)

BREATHING PATTERN:
Quick, rhythmic breathing matching leg tempo

KEY POINTS:
• Hips stay LOW (don't pike up)
• Core stays engaged entire time
• Quick, controlled movement
• Land softly on toes

SAFETY NOTES:
• Stop if wrist pain
• Stop if lower back pain
• Slow down if losing form''',
        ),
        animationPath: const Value('assets/animations/level3/mountain_climbers.json'),
        setsReps: const Value('3 sets x 20 seconds'),
        durationSeconds: const Value(60),
        orderIndex: const Value(3),
      ),

      // Exercise 4: Dead Bugs
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Dead Bugs'),
        description: const Value(
          '''STARTING POSITION:
• Lie on back
• Knees bent at 90 degrees (tabletop position)
• Arms extended straight up toward ceiling
• Lower back pressed flat against floor

STEP-BY-STEP EXECUTION:

1. PREPARE:
   - Press lower back into floor
   - Engage core deeply

2. EXTEND (exhale):
   - Exhale through mouth
   - Slowly lower RIGHT arm overhead (behind head)
   - Simultaneously extend LEFT leg straight out
   - Both limbs hover 2-3 inches off floor
   - Lower back MUST stay flat on floor
   - Hold 1-2 seconds

3. RETURN (inhale):
   - Inhale through nose
   - Return arm and leg to starting position
   - Maintain core engagement

4. SWITCH SIDES:
   - Left arm + right leg

PROGRESSION:
Week 1-2: Arm only OR leg only
Week 3-4: Arm + leg, partial range
Week 5+: Full range, add 3-second hold

BREATHING PATTERN:
Inhale (starting position) → Exhale (extend) → Inhale (return)

KEY POINTS:
• Lower back NEVER arches off floor
• Move SLOWLY and controlled
• Only extend as far as back stays flat
• Opposite arm and leg move together

SAFETY NOTES:
• Stop if back arches (reduce range of motion)
• This exercise is diastasis recti safe
• Stop if neck pain (support head with pillow)''',
        ),
        animationPath: const Value('assets/animations/level3/dead_bugs.json'),
        setsReps: const Value('3 sets x 10 reps each side'),
        durationSeconds: const Value(120),
        orderIndex: const Value(4),
      ),

      // Exercise 5: Jump Squats (Advanced)
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Jump Squats'),
        description: const Value(
          '''STARTING POSITION:
• Stand with feet hip-width apart
• Hands at chest or sides
• Core engaged

STEP-BY-STEP EXECUTION:

1. SQUAT DOWN (inhale):
   - Lower into squat position
   - Thighs parallel to floor
   - Weight in heels
   - Arms swing back

2. EXPLODE UP (exhale):
   - Powerfully jump straight up
   - Extend hips, knees, ankles fully
   - Arms swing forward and up
   - Leave ground

3. LAND SOFTLY (inhale):
   - Land toe-ball-heel (soft landing)
   - Immediately lower back into squat
   - Absorb impact with legs
   - No pause at bottom

4. IMMEDIATELY REPEAT

PREREQUISITES:
• Must pass return-to-running test
• No pelvic floor symptoms
• No leaking during jumping
• Doctor clearance required

BREATHING PATTERN:
Inhale (squat) → Exhale (jump) → Inhale (land)

KEY POINTS:
• Land SOFTLY (toes first)
• Engage pelvic floor BEFORE jumping
• No pause between reps
• Explosive power from hips

SAFETY NOTES:
• DO NOT do if any pelvic floor issues
• DO NOT do if any leaking/heaviness
• Requires medical clearance
• Not for everyone - alternative: regular squats''',
        ),
        animationPath: const Value('assets/animations/level3/jump_squats.json'),
        setsReps: const Value('3 sets x 10 reps'),
        durationSeconds: const Value(60),
        orderIndex: const Value(5),
      ),
    ];

    await db.exerciseDao.insertMultipleExercises(exercises);
  }
}
