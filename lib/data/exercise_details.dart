/// Detailed exercise information for all postpartum exercises
class ExerciseDetail {
  final String name;
  final int level;
  final String duration;
  final String difficulty;
  final String animationPath;
  final String description;
  final List<String> startingPosition;
  final List<ExerciseStep> steps;
  final String breathingPattern;
  final List<String> keyPoints;
  final List<String> safetyNotes;
  final List<String> commonMistakes;
  final String? sets;
  final String? reps;

  const ExerciseDetail({
    required this.name,
    required this.level,
    required this.duration,
    required this.difficulty,
    required this.animationPath,
    required this.description,
    required this.startingPosition,
    required this.steps,
    required this.breathingPattern,
    required this.keyPoints,
    required this.safetyNotes,
    required this.commonMistakes,
    this.sets,
    this.reps,
  });
}

class ExerciseStep {
  final String title;
  final List<String> instructions;
  final String? duration;

  const ExerciseStep({
    required this.title,
    required this.instructions,
    this.duration,
  });
}

/// All exercise details organized by level
class ExerciseDatabase {
  static const Map<String, ExerciseDetail> exercises = {
    // LEVEL 1: REPAIR (0-6 weeks)
    'diaphragmatic_breathing': ExerciseDetail(
      name: 'Diaphragmatic Breathing',
      level: 1,
      duration: '2 minutes',
      difficulty: 'Beginner',
      animationPath: 'assets/animations/breathing.json',
      description: 'Core foundation breathing exercise to reconnect with your diaphragm and pelvic floor.',
      startingPosition: [
        'Lie on back with knees bent, feet flat on floor hip-width apart',
        'One hand on chest, one hand on belly',
        'Head supported by pillow (optional)',
        'Neutral spine with natural curve in lower back',
      ],
      steps: [
        ExerciseStep(
          title: 'INHALE',
          duration: '4 seconds',
          instructions: [
            'Breathe in slowly through NOSE',
            'Feel belly RISE and EXPAND like a balloon',
            'Hand on belly should lift UP',
            'Chest stays relatively STILL',
            'Pelvic floor muscles gently RELAX',
          ],
        ),
        ExerciseStep(
          title: 'EXHALE',
          duration: '6 seconds',
          instructions: [
            'Breathe out slowly through MOUTH (pursed lips)',
            'Feel belly DEFLATE and FLATTEN',
            'Hand on belly lowers DOWN',
            'Gently engage pelvic floor',
            'Belly button draws IN toward spine',
          ],
        ),
        ExerciseStep(
          title: 'PAUSE',
          duration: '2 seconds',
          instructions: [
            'Brief rest before next breath',
            'Complete relaxation',
          ],
        ),
      ],
      breathingPattern: 'Inhale 4s → Exhale 6s → Pause 2s',
      keyPoints: [
        'Foundation for all other exercises',
        'Can be done immediately after birth',
        'Practice 3-5 times daily',
        'Sets foundation for pelvic floor connection',
      ],
      safetyNotes: [
        'Never hold breath',
        'Don\'t force belly movement',
        'Stop if dizzy',
      ],
      commonMistakes: [
        'Chest breathing instead of belly',
        'Holding breath',
        'Forcing exhale too hard',
        'Breathing too quickly',
      ],
      reps: '10-15 breaths',
    ),

    'pelvic_floor_activation': ExerciseDetail(
      name: 'Pelvic Floor Activation (Kegels)',
      level: 1,
      duration: '3 minutes',
      difficulty: 'Beginner',
      animationPath: 'assets/animations/kegels.json',
      description: 'Strengthen and reconnect with your pelvic floor muscles.',
      startingPosition: [
        'Sit comfortably on chair or lie on back',
        'Feet flat on floor',
        'Spine neutral, shoulders relaxed',
      ],
      steps: [
        ExerciseStep(
          title: 'SLOW HOLDS',
          instructions: [
            'Inhale to prepare',
            'Exhale and squeeze pelvic floor UP',
            'Imagine stopping urine mid-flow',
            'Hold 5-10 seconds',
            'Maintain normal breathing',
            'Release completely for 5 seconds',
          ],
        ),
        ExerciseStep(
          title: 'QUICK PULSES',
          instructions: [
            'Quick squeeze (1 second)',
            'Quick release (1 second)',
            'Repeat rapidly 10 times',
          ],
        ),
      ],
      breathingPattern: 'Inhale to prepare → Exhale during squeeze',
      keyPoints: [
        'Should feel internal lifting sensation',
        'No visible external movement',
        'Relaxation between reps is essential',
        'Do NOT squeeze glutes or thighs',
      ],
      safetyNotes: [
        'Stop if pain or heaviness increases',
        'Never bear down or push OUT',
        'See pelvic floor PT if unsure',
      ],
      commonMistakes: [
        'Bearing down instead of lifting',
        'Holding breath',
        'Squeezing glutes or thighs',
        'Not fully relaxing between reps',
      ],
      sets: '3',
      reps: '10 slow + 10 quick',
    ),

    'pelvic_tilts': ExerciseDetail(
      name: 'Pelvic Tilts',
      level: 1,
      duration: '2 minutes',
      difficulty: 'Beginner',
      animationPath: 'assets/animations/pelvic_tilts.json',
      description: 'Gentle movement to reconnect with your core and relieve lower back tension.',
      startingPosition: [
        'Lie on back',
        'Knees bent, feet flat on floor hip-width apart',
        'Arms relaxed at sides',
        'Neutral spine',
      ],
      steps: [
        ExerciseStep(
          title: 'POSTERIOR TILT',
          duration: 'Hold 3 seconds',
          instructions: [
            'Exhale through mouth',
            'Press lower back FLAT against floor',
            'Tailbone tucks UNDER slightly',
            'Belly button draws IN toward spine',
            'Hold 3 seconds',
          ],
        ),
        ExerciseStep(
          title: 'RETURN TO NEUTRAL',
          instructions: [
            'Inhale through nose',
            'Gently release',
            'Return to natural curve',
          ],
        ),
      ],
      breathingPattern: 'Inhale (neutral) → Exhale (flatten) → Hold 3s',
      keyPoints: [
        'Movement comes from PELVIS',
        'Gentle core engagement',
        'Avoid squeezing glutes',
        'Small, controlled movement',
      ],
      safetyNotes: [
        'Safe for diastasis recti',
        'Stop if back pain occurs',
      ],
      commonMistakes: [
        'Pushing through feet instead of abs',
        'Squeezing glutes excessively',
        'Moving too quickly',
      ],
      reps: '10',
    ),

    'cat_cow': ExerciseDetail(
      name: 'Cat-Cow Stretch',
      level: 1,
      duration: '2 minutes',
      difficulty: 'Beginner',
      animationPath: 'assets/animations/cat_cow.json',
      description: 'Gentle spinal mobility exercise to relieve tension and improve posture.',
      startingPosition: [
        'All fours (hands and knees)',
        'Hands directly under shoulders',
        'Knees directly under hips',
        'Neutral spine (flat back)',
      ],
      steps: [
        ExerciseStep(
          title: 'CAT POSE',
          duration: 'Hold 3 seconds',
          instructions: [
            'Exhale through mouth',
            'Round spine UP toward ceiling',
            'Tuck chin to chest',
            'Tailbone tucks UNDER',
            'Belly button draws IN',
          ],
        ),
        ExerciseStep(
          title: 'RETURN TO NEUTRAL',
          instructions: [
            'Inhale through nose',
            'Return to flat back ONLY',
            'DO NOT arch back (modified for postpartum)',
            'Keep core engaged',
          ],
        ),
      ],
      breathingPattern: 'Inhale (neutral) → Exhale (cat) → Hold 3s',
      keyPoints: [
        'MODIFIED: Do NOT arch back',
        'Movement from pelvis/tailbone',
        'Shoulders stay relaxed',
        'Wrists aligned under shoulders',
      ],
      safetyNotes: [
        'DO NOT arch if you have diastasis recti',
        'Stop if wrist pain',
        'Stop if back pain',
      ],
      commonMistakes: [
        'Arching back too much',
        'Hyperextending neck',
        'Moving too quickly',
      ],
      reps: '10',
    ),

    'heel_slides': ExerciseDetail(
      name: 'Heel Slides',
      level: 1,
      duration: '2 minutes',
      difficulty: 'Beginner',
      animationPath: 'assets/animations/ankle_pumps.json',
      description: 'Core stability exercise that challenges your ability to maintain neutral spine.',
      startingPosition: [
        'Lie on back',
        'Both knees bent, feet flat on floor',
        'Arms at sides',
        'Neutral spine',
      ],
      steps: [
        ExerciseStep(
          title: 'ENGAGE CORE',
          instructions: [
            'Belly button draws gently IN',
            'Pelvic floor lightly engaged',
            'Lower back maintains floor contact',
          ],
        ),
        ExerciseStep(
          title: 'SLIDE HEEL OUT',
          instructions: [
            'Exhale through mouth',
            'Slowly slide ONE heel away',
            'Keep lower back FLAT on floor',
            'Stop if back starts to arch',
            'Hold 2 seconds',
          ],
        ),
        ExerciseStep(
          title: 'SLIDE HEEL BACK',
          instructions: [
            'Inhale through nose',
            'Slowly slide heel back',
            'Maintain core engagement',
            'Switch legs',
          ],
        ),
      ],
      breathingPattern: 'Inhale (prepare) → Exhale (slide out) → Inhale (back)',
      keyPoints: [
        'Core engaged ENTIRE time',
        'Lower back must NOT arch',
        'Move slowly and controlled',
        'Range of motion varies',
      ],
      safetyNotes: [
        'Stop when back starts to arch',
        'Safe for diastasis recti',
      ],
      commonMistakes: [
        'Allowing back to arch',
        'Moving too quickly',
        'Not engaging core',
        'Holding breath',
      ],
      reps: '10 each leg',
    ),

    // LEVEL 2: REBUILD (6-12 weeks)
    'glute_bridges': ExerciseDetail(
      name: 'Glute Bridges',
      level: 2,
      duration: '3 minutes',
      difficulty: 'Intermediate',
      animationPath: 'assets/animations/bridges.json',
      description: 'Strengthen glutes and hamstrings while engaging core.',
      startingPosition: [
        'Lie on back',
        'Knees bent, feet flat hip-width apart',
        'Heels 6-8 inches from glutes',
        'Arms at sides, palms down',
      ],
      steps: [
        ExerciseStep(
          title: 'PREPARE',
          instructions: [
            'Take deep breath',
            'Engage pelvic floor',
            'Engage core',
          ],
        ),
        ExerciseStep(
          title: 'LIFT HIPS',
          duration: 'Hold 2-3 seconds',
          instructions: [
            'Exhale through mouth',
            'Press through HEELS',
            'Lift hips UP toward ceiling',
            'Squeeze glutes at top',
            'Form straight line: shoulders → hips → knees',
          ],
        ),
        ExerciseStep(
          title: 'LOWER',
          instructions: [
            'Inhale through nose',
            'Slowly lower hips',
            'Control the descent',
          ],
        ),
      ],
      breathingPattern: 'Inhale (prepare) → Exhale (lift) → Hold → Inhale (lower)',
      keyPoints: [
        'Drive through HEELS',
        'Glutes do the work',
        'Maintain straight line',
        'Control both phases',
      ],
      safetyNotes: [
        'Do NOT overarch lower back',
        'Stop if lower back pain',
        'Keep knees over toes',
      ],
      commonMistakes: [
        'Lifting too high',
        'Pushing through toes',
        'Knees falling inward',
        'Not engaging glutes',
      ],
      sets: '3',
      reps: '10',
    ),

    'modified_planks': ExerciseDetail(
      name: 'Modified Planks',
      level: 2,
      duration: '2 minutes',
      difficulty: 'Intermediate',
      animationPath: 'assets/animations/modified_planks.json',
      description: 'Build core strength and stability with knee support.',
      startingPosition: [
        'All fours (hands and knees)',
        'Hands under shoulders',
        'Walk knees back slightly',
        'Body forms line: head → hips → knees',
      ],
      steps: [
        ExerciseStep(
          title: 'SET UP',
          instructions: [
            'Walk knees BACK 6-12 inches',
            'Hands remain under shoulders',
            'Engage core (belly IN)',
            'Shift weight over hands',
          ],
        ),
        ExerciseStep(
          title: 'HOLD PLANK',
          duration: '15-30 seconds',
          instructions: [
            'Maintain straight line',
            'Don\'t let hips sag',
            'Don\'t pike hips up',
            'Engage glutes lightly',
            'Breathe normally',
          ],
        ),
      ],
      breathingPattern: 'Steady breathing: 4s in / 4s out',
      keyPoints: [
        'Weight OVER hands',
        'Core engaged entire time',
        'Neutral neck',
        'Knees for support only',
      ],
      safetyNotes: [
        'Stop if belly domes',
        'Stop if lower back pain',
      ],
      commonMistakes: [
        'Hips sagging down',
        'Hips piking up',
        'Holding breath',
        'Shrugging shoulders',
      ],
      sets: '3',
      reps: '15-30 second holds',
    ),

    'bodyweight_squats': ExerciseDetail(
      name: 'Bodyweight Squats',
      level: 2,
      duration: '3 minutes',
      difficulty: 'Intermediate',
      animationPath: 'assets/animations/squats.json',
      description: 'Fundamental lower body exercise for functional strength.',
      startingPosition: [
        'Stand feet hip to shoulder-width apart',
        'Toes pointed forward or slightly out',
        'Arms in front for balance',
        'Chest up, shoulders back',
      ],
      steps: [
        ExerciseStep(
          title: 'LOWER DOWN',
          instructions: [
            'Hinge at HIPS first',
            'Bend knees, lower body',
            'Knees track over toes',
            'Keep chest UP',
            'Lower until thighs parallel',
            'Heels stay planted',
          ],
        ),
        ExerciseStep(
          title: 'STAND UP',
          instructions: [
            'Exhale through mouth',
            'Press through HEELS',
            'Squeeze glutes at top',
            'Fully extend hips and knees',
          ],
        ),
      ],
      breathingPattern: 'Inhale (lower) → Exhale (stand)',
      keyPoints: [
        'SIT BACK, not just down',
        'Chest stays UP',
        'Heels planted',
        'Knees track over toes',
      ],
      safetyNotes: [
        'Use chair for support if needed',
        'Don\'t go below parallel if knee pain',
        'Stop if pelvic pressure',
      ],
      commonMistakes: [
        'Knees caving inward',
        'Rising onto toes',
        'Rounding back',
        'Not sitting back enough',
      ],
      sets: '3',
      reps: '12',
    ),

    'bird_dog': ExerciseDetail(
      name: 'Bird Dog',
      level: 2,
      duration: '3 minutes',
      difficulty: 'Intermediate',
      animationPath: 'assets/animations/bird_dog.json',
      description: 'Core stability exercise that challenges balance and coordination.',
      startingPosition: [
        'All fours (hands and knees)',
        'Hands under shoulders, knees under hips',
        'Neutral spine (flat back)',
        'Core engaged',
      ],
      steps: [
        ExerciseStep(
          title: 'EXTEND',
          duration: 'Hold 3-5 seconds',
          instructions: [
            'Exhale through mouth',
            'Extend RIGHT arm forward (thumb up)',
            'Simultaneously extend LEFT leg back',
            'Keep parallel to floor',
            'Form straight line',
            'Don\'t rotate hips',
          ],
        ),
        ExerciseStep(
          title: 'RETURN',
          instructions: [
            'Inhale through nose',
            'Return to start',
            'Switch sides',
          ],
        ),
      ],
      breathingPattern: 'Inhale (prepare) → Exhale (extend) → Inhale (return)',
      keyPoints: [
        'Minimize spine movement',
        'Hips stay LEVEL',
        'Slow, controlled',
        'Core engaged entire time',
      ],
      safetyNotes: [
        'Stop if back pain',
        'Regress to arm or leg only if wobbling',
      ],
      commonMistakes: [
        'Rotating hips/shoulders',
        'Arching lower back',
        'Moving too quickly',
        'Raising limbs too high',
      ],
      reps: '10 each side',
    ),

    'wall_pushups': ExerciseDetail(
      name: 'Wall Push-ups',
      level: 2,
      duration: '2 minutes',
      difficulty: 'Intermediate',
      animationPath: 'assets/animations/wall_pushups.json',
      description: 'Upper body strengthening with wall support for beginners.',
      startingPosition: [
        'Face wall, arm\'s length away',
        'Hands on wall at shoulder height',
        'Hands shoulder-width apart',
        'Feet hip-width apart',
      ],
      steps: [
        ExerciseStep(
          title: 'LOWER',
          instructions: [
            'Bend elbows',
            'Lower chest toward wall',
            'Elbows at 45-degree angle',
            'Keep body straight',
            'Lower until nose almost touches',
          ],
        ),
        ExerciseStep(
          title: 'PUSH AWAY',
          instructions: [
            'Exhale through mouth',
            'Press through palms',
            'Straighten arms',
            'Return to start',
          ],
        ),
      ],
      breathingPattern: 'Inhale (lower) → Exhale (push)',
      keyPoints: [
        'Body stays straight',
        'Elbows at 45 degrees',
        'Control both phases',
        'Full range of motion',
      ],
      safetyNotes: [
        'Stop if shoulder pain',
        'Don\'t flare elbows out',
        'Keep core engaged',
      ],
      commonMistakes: [
        'Bending at hips',
        'Elbows flaring out',
        'Not full range',
        'Rushing',
      ],
      sets: '3',
      reps: '10',
    ),

    // LEVEL 3: STRENGTHEN (12+ weeks)
    'full_planks': ExerciseDetail(
      name: 'Full Plank',
      level: 3,
      duration: '3 minutes',
      difficulty: 'Advanced',
      animationPath: 'assets/animations/full_planks.json',
      description: 'Advanced core stability exercise for full-body strength.',
      startingPosition: [
        'Face down on mat',
        'Forearms on ground, elbows under shoulders',
        'Toes tucked under',
      ],
      steps: [
        ExerciseStep(
          title: 'LIFT INTO PLANK',
          instructions: [
            'Press up onto forearms and toes',
            'Body forms straight line',
            'Core pulled IN tight',
            'Glutes squeezed',
            'Quads engaged',
          ],
        ),
        ExerciseStep(
          title: 'HOLD',
          duration: '30-60 seconds',
          instructions: [
            'Breathe normally',
            'Maintain alignment',
            'Eyes look down',
          ],
        ),
      ],
      breathingPattern: 'Steady: 4s in / 4s out',
      keyPoints: [
        'Perfect alignment is KEY',
        'Core drives stability',
        'Squeeze glutes',
        'Neutral neck',
      ],
      safetyNotes: [
        'Stop if belly domes',
        'Stop if lower back pain',
        'Don\'t exceed 60s',
      ],
      commonMistakes: [
        'Hips sagging',
        'Hips too high',
        'Holding breath',
        'Shoulders shrugged',
      ],
      sets: '3',
      reps: '30-60 second holds',
    ),

    'lunges': ExerciseDetail(
      name: 'Lunges',
      level: 3,
      duration: '4 minutes',
      difficulty: 'Advanced',
      animationPath: 'assets/animations/lunges.json',
      description: 'Single-leg strength exercise for balance and power.',
      startingPosition: [
        'Stand tall, feet hip-width apart',
        'Hands on hips or at sides',
        'Chest up, shoulders back',
        'Core engaged',
      ],
      steps: [
        ExerciseStep(
          title: 'STEP FORWARD',
          instructions: [
            'Step forward with right foot',
            'Land heel first',
            'Keep torso upright',
          ],
        ),
        ExerciseStep(
          title: 'LOWER DOWN',
          instructions: [
            'Bend both knees',
            'Lower back knee toward floor',
            'Front knee over ankle',
            'Back knee hovers 1-2 inches off floor',
          ],
        ),
        ExerciseStep(
          title: 'PUSH BACK',
          instructions: [
            'Press through front heel',
            'Return to start',
            'Alternate legs',
          ],
        ),
      ],
      breathingPattern: 'Inhale (step/lower) → Exhale (push back)',
      keyPoints: [
        'Front knee over ankle',
        'Torso stays UPRIGHT',
        'Back knee hovers',
        'Weight in front heel',
      ],
      safetyNotes: [
        'Use wall for balance',
        'Stop if knee pain',
        'Reverse lunges easier on knees',
      ],
      commonMistakes: [
        'Knee going too far forward',
        'Leaning forward',
        'Back knee slamming down',
        'Too short step',
      ],
      sets: '3',
      reps: '10 each leg',
    ),

    'mountain_climbers': ExerciseDetail(
      name: 'Mountain Climbers',
      level: 3,
      duration: '2 minutes',
      difficulty: 'Advanced',
      animationPath: 'assets/animations/mountain_climbers.json',
      description: 'Dynamic cardio exercise that builds core strength and endurance.',
      startingPosition: [
        'High plank position',
        'Hands under shoulders',
        'Body in straight line',
        'Core engaged',
      ],
      steps: [
        ExerciseStep(
          title: 'DRIVE KNEE IN',
          instructions: [
            'Drive RIGHT knee toward chest',
            'Keep hips low',
            'Tap toe near hands',
          ],
        ),
        ExerciseStep(
          title: 'SWITCH',
          instructions: [
            'Quickly switch legs',
            'Drive LEFT knee to chest',
            'Continue alternating',
          ],
        ),
      ],
      breathingPattern: 'Quick rhythmic breathing matching tempo',
      keyPoints: [
        'Hips stay LOW',
        'Core engaged',
        'Quick, controlled',
        'Land softly',
      ],
      safetyNotes: [
        'Stop if wrist pain',
        'Stop if back pain',
        'Slow down if losing form',
      ],
      commonMistakes: [
        'Hips piking up',
        'Shoulders moving',
        'Landing heavily',
        'Losing control',
      ],
      sets: '3',
      reps: '20 seconds',
    ),

    'dead_bugs': ExerciseDetail(
      name: 'Dead Bugs',
      level: 3,
      duration: '3 minutes',
      difficulty: 'Advanced',
      animationPath: 'assets/animations/dead_bugs.json',
      description: 'Advanced core stability exercise that\'s safe for diastasis recti.',
      startingPosition: [
        'Lie on back',
        'Knees bent at 90 degrees (tabletop)',
        'Arms extended up toward ceiling',
        'Lower back pressed flat against floor',
      ],
      steps: [
        ExerciseStep(
          title: 'EXTEND',
          duration: 'Hold 1-2 seconds',
          instructions: [
            'Exhale through mouth',
            'Lower RIGHT arm overhead',
            'Simultaneously extend LEFT leg',
            'Both hover 2-3 inches off floor',
            'Back MUST stay flat',
          ],
        ),
        ExerciseStep(
          title: 'RETURN',
          instructions: [
            'Inhale through nose',
            'Return to start',
            'Switch sides',
          ],
        ),
      ],
      breathingPattern: 'Inhale (start) → Exhale (extend) → Inhale (return)',
      keyPoints: [
        'Back NEVER arches',
        'Move SLOWLY',
        'Only extend as far as back stays flat',
        'Opposite arm and leg',
      ],
      safetyNotes: [
        'Stop if back arches',
        'Safe for diastasis recti',
        'Use pillow under head if needed',
      ],
      commonMistakes: [
        'Back arching off floor',
        'Moving too quickly',
        'Extending too far',
        'Holding breath',
      ],
      sets: '3',
      reps: '10 each side',
    ),

    'jump_squats': ExerciseDetail(
      name: 'Jump Squats',
      level: 3,
      duration: '2 minutes',
      difficulty: 'Advanced',
      animationPath: 'assets/animations/jump_squats.json',
      description: 'Plyometric exercise for power. ONLY if cleared by doctor.',
      startingPosition: [
        'Stand feet hip-width apart',
        'Hands at chest or sides',
        'Core engaged',
      ],
      steps: [
        ExerciseStep(
          title: 'SQUAT DOWN',
          instructions: [
            'Lower into squat',
            'Thighs parallel to floor',
            'Weight in heels',
            'Arms swing back',
          ],
        ),
        ExerciseStep(
          title: 'EXPLODE UP',
          instructions: [
            'Jump straight up',
            'Extend hips, knees, ankles',
            'Arms swing forward',
          ],
        ),
        ExerciseStep(
          title: 'LAND SOFTLY',
          instructions: [
            'Land toe-ball-heel',
            'Immediately lower to squat',
            'Absorb impact with legs',
          ],
        ),
      ],
      breathingPattern: 'Inhale (squat) → Exhale (jump) → Inhale (land)',
      keyPoints: [
        'Land SOFTLY',
        'Engage pelvic floor BEFORE jumping',
        'No pause between reps',
        'Explosive power from hips',
      ],
      safetyNotes: [
        'DO NOT do if pelvic floor issues',
        'DO NOT do if any leaking',
        'Requires medical clearance',
        'Not for everyone',
      ],
      commonMistakes: [
        'Landing hard on heels',
        'Knees caving on landing',
        'Not engaging pelvic floor',
        'Jumping when not ready',
      ],
      sets: '3',
      reps: '10',
    ),
  };

  static ExerciseDetail? getExercise(String key) => exercises[key];

  static List<ExerciseDetail> getExercisesByLevel(int level) {
    return exercises.values.where((e) => e.level == level).toList();
  }
}
