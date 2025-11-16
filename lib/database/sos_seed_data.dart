import 'package:drift/drift.dart';
import 'app_database.dart';

/// Seed data for SOS routines and exercises
class SosSeedData {
  static Future<void> seedSosData(AppDatabase db) async {
    // Check if data already exists
    final existingRoutines = await db.sosRoutineDao.getAllSosRoutines();
    if (existingRoutines.isNotEmpty) {
      return; // Data already seeded
    }

    // Seed SOS Routines
    final routines = [
      SosRoutinesCompanion.insert(
        name: 'Back Pain Relief',
        description:
            'Quick relief exercises for postpartum back pain and tension',
        iconEmoji: '🫸',
        durationMinutes: 5,
        exerciseCount: 3,
        difficulty: 'easy',
        safetyWarning: const Value('Stop if pain increases'),
        tips: const Value('Breathe deeply during each movement'),
        orderIndex: 1,
      ),
      SosRoutinesCompanion.insert(
        name: 'Pelvic Heaviness',
        description:
            'Relieve pelvic pressure and heaviness with gentle movements',
        iconEmoji: '🌸',
        durationMinutes: 4,
        exerciseCount: 3,
        difficulty: 'easy',
        safetyWarning: const Value('Stop if discomfort increases'),
        tips: const Value('Rest with legs elevated after'),
        orderIndex: 2,
      ),
      SosRoutinesCompanion.insert(
        name: 'C-Section Scar Pain',
        description: 'Gentle exercises to reduce scar tissue discomfort',
        iconEmoji: '✨',
        durationMinutes: 3,
        exerciseCount: 3,
        difficulty: 'easy',
        safetyWarning:
            const Value('Wait until incision is fully healed (6+ weeks)'),
        tips: const Value('Use gentle, circular motions'),
        orderIndex: 3,
      ),
      SosRoutinesCompanion.insert(
        name: 'Diastasis Recti Flare',
        description: 'Targeted exercises to support abdominal separation',
        iconEmoji: '💪',
        durationMinutes: 6,
        exerciseCount: 4,
        difficulty: 'moderate',
        safetyWarning: const Value('Avoid crunches and forward flexion'),
        tips: const Value('Engage transverse abdominis before each movement'),
        orderIndex: 4,
      ),
      SosRoutinesCompanion.insert(
        name: 'Pelvic Floor Overactivity',
        description: 'Relaxation techniques for tight pelvic floor muscles',
        iconEmoji: '🧘',
        durationMinutes: 5,
        exerciseCount: 3,
        difficulty: 'easy',
        safetyWarning: const Value(null),
        tips: const Value('Practice before bed for better sleep'),
        orderIndex: 5,
      ),
    ];

    // Insert routines and get their IDs
    final routineIds = <int>[];
    for (final routine in routines) {
      final id = await db.sosRoutineDao.insertSosRoutine(routine);
      routineIds.add(id);
    }

    // ============================================================================
    // ROUTINE 1: Back Pain Relief (5 min)
    // ============================================================================

    final backPainExercises = [
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[0],
        exerciseName: 'Cat-Cow Stretch',
        description:
            'Gently arch and round your back to release tension in the spine',
        animationPath: 'assets/animations/sos/cat_cow.json',
        durationSeconds: 120,
        audioGuidance:
            'Start on your hands and knees. Inhale as you arch your back, lifting your head. Exhale as you round your spine, tucking your chin. Move slowly and breathe deeply.',
        orderIndex: 1,
      ),
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[0],
        exerciseName: 'Child\'s Pose',
        description:
            'A gentle resting pose that stretches the lower back and hips',
        animationPath: 'assets/animations/sos/childs_pose.json',
        durationSeconds: 120,
        audioGuidance:
            'Sit back on your heels and fold forward, extending your arms in front. Rest your forehead on the mat. Breathe deeply and relax your back.',
        orderIndex: 2,
      ),
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[0],
        exerciseName: 'Gentle Spinal Twist',
        description: 'Release tension in the spine with a gentle twist',
        animationPath: 'assets/animations/sos/spinal_twist.json',
        durationSeconds: 60,
        audioGuidance:
            'Lie on your back with knees bent. Let your knees fall to one side while keeping shoulders on the mat. Hold for a few breaths, then switch sides.',
        orderIndex: 3,
      ),
    ];

    // ============================================================================
    // ROUTINE 2: Pelvic Heaviness (4 min)
    // ============================================================================

    final pelvicHeavinessExercises = [
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[1],
        exerciseName: 'Pelvic Floor Release',
        description: 'Gentle breathing to release pelvic floor tension',
        animationPath: 'assets/animations/sos/pelvic_floor_release.json',
        durationSeconds: 120,
        audioGuidance:
            'Lie on your back with knees bent. Take slow, deep breaths. As you inhale, imagine your pelvic floor gently dropping. As you exhale, let it relax completely.',
        orderIndex: 1,
      ),
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[1],
        exerciseName: 'Happy Baby Pose',
        description: 'Opens the hips and relieves pelvic pressure',
        animationPath: 'assets/animations/sos/happy_baby.json',
        durationSeconds: 90,
        audioGuidance:
            'Lie on your back and bring your knees toward your chest. Hold the outside of your feet and gently pull your knees toward your armpits. Rock gently side to side.',
        orderIndex: 2,
      ),
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[1],
        exerciseName: 'Legs Up Wall',
        description: 'Reduces pelvic pressure and improves circulation',
        animationPath: 'assets/animations/sos/legs_up_wall.json',
        durationSeconds: 30,
        audioGuidance:
            'Lie on your back and place your legs up against a wall. Relax your arms by your sides and breathe deeply. Stay here for a few breaths.',
        orderIndex: 3,
      ),
    ];

    // ============================================================================
    // ROUTINE 3: C-Section Scar Pain (3 min)
    // ============================================================================

    final csectionExercises = [
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[2],
        exerciseName: 'Scar Tissue Massage',
        description: 'Gentle massage to reduce scar tissue adhesions',
        animationPath: 'assets/animations/sos/scar_massage.json',
        durationSeconds: 60,
        audioGuidance:
            'Using gentle pressure, massage around your scar in small circles. Move slowly and stop if you feel any sharp pain. Breathe deeply.',
        orderIndex: 1,
      ),
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[2],
        exerciseName: 'Gentle Core Engagement',
        description: 'Activate deep core muscles to support healing',
        animationPath: 'assets/animations/sos/core_engagement.json',
        durationSeconds: 60,
        audioGuidance:
            'Lie on your back with knees bent. Take a deep breath. As you exhale, gently draw your belly button toward your spine. Hold for a few seconds, then release.',
        orderIndex: 2,
      ),
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[2],
        exerciseName: 'Diaphragmatic Breathing',
        description: 'Deep breathing to promote healing and relaxation',
        animationPath: 'assets/animations/sos/diaphragm_breathing.json',
        durationSeconds: 60,
        audioGuidance:
            'Place one hand on your chest and one on your belly. Breathe deeply so that your belly rises more than your chest. This helps engage your core gently.',
        orderIndex: 3,
      ),
    ];

    // ============================================================================
    // ROUTINE 4: Diastasis Recti Flare (6 min)
    // ============================================================================

    final diastasisExercises = [
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[3],
        exerciseName: 'Transverse Abdominis Activation',
        description: 'Activate the deepest core muscle to support healing',
        animationPath: 'assets/animations/sos/ta_activation.json',
        durationSeconds: 120,
        audioGuidance:
            'Lie on your back with knees bent. Exhale and gently draw your lower belly in, as if pulling your hip bones together. Hold for 5 seconds, then release. Repeat.',
        orderIndex: 1,
      ),
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[3],
        exerciseName: 'Modified Plank',
        description: 'Strengthen core while protecting abdominal separation',
        animationPath: 'assets/animations/sos/modified_plank.json',
        durationSeconds: 120,
        audioGuidance:
            'Start on your hands and knees. Engage your core and hold this position, keeping your back straight. Breathe steadily. If comfortable, extend one leg at a time.',
        orderIndex: 2,
      ),
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[3],
        exerciseName: 'Pelvic Tilts',
        description: 'Gentle movement to engage core without strain',
        animationPath: 'assets/animations/sos/pelvic_tilts.json',
        durationSeconds: 60,
        audioGuidance:
            'Lie on your back with knees bent. Gently tilt your pelvis, pressing your lower back into the mat. Hold for a few seconds, then release. Move slowly.',
        orderIndex: 3,
      ),
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[3],
        exerciseName: 'Rest and Recovery',
        description: 'Allow your body to rest and integrate the work',
        animationPath: 'assets/animations/sos/rest.json',
        durationSeconds: 60,
        audioGuidance:
            'Lie on your back with knees bent or legs extended. Close your eyes and breathe deeply. Allow your body to rest and recover.',
        orderIndex: 4,
      ),
    ];

    // ============================================================================
    // ROUTINE 5: Pelvic Floor Overactivity (5 min)
    // ============================================================================

    final pelvicFloorRelaxExercises = [
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[4],
        exerciseName: 'Deep Belly Breathing',
        description: 'Use breath to relax overactive pelvic floor muscles',
        animationPath: 'assets/animations/sos/deep_breathing.json',
        durationSeconds: 120,
        audioGuidance:
            'Sit or lie comfortably. Place one hand on your belly. Breathe deeply into your belly, allowing it to expand. As you exhale, let your pelvic floor relax completely.',
        orderIndex: 1,
      ),
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[4],
        exerciseName: 'Pelvic Floor Drop',
        description: 'Consciously release tension in pelvic floor muscles',
        animationPath: 'assets/animations/sos/pf_drop.json',
        durationSeconds: 120,
        audioGuidance:
            'Lie on your back with knees bent. Imagine your pelvic floor as an elevator. As you breathe in, let the elevator go down to the basement. Feel the gentle release.',
        orderIndex: 2,
      ),
      SosExercisesCompanion.insert(
        sosRoutineId: routineIds[4],
        exerciseName: 'Progressive Muscle Relaxation',
        description: 'Release tension throughout the body',
        animationPath: 'assets/animations/sos/muscle_relaxation.json',
        durationSeconds: 60,
        audioGuidance:
            'Starting at your feet, tense each muscle group for 5 seconds, then release. Move up your body: legs, hips, belly, chest, arms, and face. End with full body relaxation.',
        orderIndex: 3,
      ),
    ];

    // Insert all exercises
    await db.sosRoutineDao.insertMultipleSosExercises(backPainExercises);
    await db.sosRoutineDao.insertMultipleSosExercises(pelvicHeavinessExercises);
    await db.sosRoutineDao.insertMultipleSosExercises(csectionExercises);
    await db.sosRoutineDao.insertMultipleSosExercises(diastasisExercises);
    await db.sosRoutineDao
        .insertMultipleSosExercises(pelvicFloorRelaxExercises);
  }
}
