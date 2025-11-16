import 'package:drift/drift.dart';
import 'app_database.dart';

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
  }

  /// Level 1: Repair (0-6 weeks) - 5 exercises, 10 min total
  static Future<void> _seedLevel1(AppDatabase db, int userId) async {
    final workoutId = await db.workoutDao.insertWorkout(
      WorkoutsCompanion(
        userId: Value(userId),
        level: const Value(1),
        name: const Value('Level 1: Repair'),
        description: const Value(
          'Gentle exercises focused on healing and early recovery. Perfect for 0-6 weeks postpartum.',
        ),
        durationMinutes: const Value(10),
        isCompleted: const Value(false),
      ),
    );

    final exercises = [
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Diaphragmatic Breathing'),
        description: const Value(
          'Lie on your back with knees bent. Place one hand on your chest and one on your belly. Breathe in deeply through your nose, feeling your belly rise. Exhale slowly through your mouth.',
        ),
        animationPath: const Value('assets/animations/level1/breathing.json'),
        setsReps: const Value('1x10'),
        durationSeconds: const Value(60),
        orderIndex: const Value(1),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Pelvic Tilts'),
        description: const Value(
          'Lie on your back with knees bent. Gently tilt your pelvis up, flattening your lower back against the floor. Hold for 3 seconds, then release.',
        ),
        animationPath: const Value('assets/animations/level1/pelvic_tilts.json'),
        setsReps: const Value('2x10'),
        durationSeconds: const Value(120),
        orderIndex: const Value(2),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Gentle Kegels'),
        description: const Value(
          'Tighten your pelvic floor muscles as if you\'re stopping the flow of urine. Hold for 3 seconds, then release for 3 seconds. Gradually increase hold time.',
        ),
        animationPath: const Value('assets/animations/level1/kegels.json'),
        setsReps: const Value('2x10'),
        durationSeconds: const Value(120),
        orderIndex: const Value(3),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Cat-Cow Stretch'),
        description: const Value(
          'Start on hands and knees. Arch your back while lifting your head and tailbone (Cow). Then round your back while tucking your chin and tailbone (Cat). Move slowly and gently.',
        ),
        animationPath: const Value('assets/animations/level1/cat_cow.json'),
        setsReps: const Value('2x10'),
        durationSeconds: const Value(120),
        orderIndex: const Value(4),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Ankle Pumps'),
        description: const Value(
          'Lie on your back. Point and flex your feet, pumping your ankles up and down. This helps improve circulation and prevent blood clots.',
        ),
        animationPath: const Value('assets/animations/level1/ankle_pumps.json'),
        setsReps: const Value('2x15'),
        durationSeconds: const Value(120),
        orderIndex: const Value(5),
      ),
    ];

    await db.exerciseDao.insertMultipleExercises(exercises);
  }

  /// Level 2: Rebuild (6-12 weeks) - 8 exercises, 15 min total
  static Future<void> _seedLevel2(AppDatabase db, int userId) async {
    final workoutId = await db.workoutDao.insertWorkout(
      WorkoutsCompanion(
        userId: Value(userId),
        level: const Value(2),
        name: const Value('Level 2: Rebuild'),
        description: const Value(
          'Moderate exercises to rebuild core strength and stability. Suitable for 6-12 weeks postpartum.',
        ),
        durationMinutes: const Value(15),
        isCompleted: const Value(false),
      ),
    );

    final exercises = [
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Bridges'),
        description: const Value(
          'Lie on your back with knees bent. Lift your hips off the ground, creating a straight line from shoulders to knees. Hold for 3 seconds, then lower.',
        ),
        animationPath: const Value('assets/animations/level2/bridges.json'),
        setsReps: const Value('3x10'),
        durationSeconds: const Value(90),
        orderIndex: const Value(1),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Wall Push-ups'),
        description: const Value(
          'Stand arm\'s length from a wall. Place hands on wall at shoulder height. Lean in, bending elbows, then push back. Keep core engaged.',
        ),
        animationPath: const Value('assets/animations/level2/wall_pushups.json'),
        setsReps: const Value('3x10'),
        durationSeconds: const Value(90),
        orderIndex: const Value(2),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Modified Planks'),
        description: const Value(
          'Start on hands and knees. Step back into a plank position on your knees. Hold with a straight line from head to knees. Keep core tight.',
        ),
        animationPath: const Value('assets/animations/level2/modified_planks.json'),
        setsReps: const Value('3x20s'),
        durationSeconds: const Value(120),
        orderIndex: const Value(3),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Side-lying Leg Lifts'),
        description: const Value(
          'Lie on your side with legs straight. Lift top leg up keeping it straight, then lower. Focus on using hip muscles, not momentum.',
        ),
        animationPath: const Value('assets/animations/level2/leg_lifts.json'),
        setsReps: const Value('3x12 each'),
        durationSeconds: const Value(120),
        orderIndex: const Value(4),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Bird Dog'),
        description: const Value(
          'Start on hands and knees. Extend right arm forward and left leg back. Hold for 3 seconds. Return and switch sides. Keep hips level.',
        ),
        animationPath: const Value('assets/animations/level2/bird_dog.json'),
        setsReps: const Value('3x10 each'),
        durationSeconds: const Value(120),
        orderIndex: const Value(5),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Glute Squeezes'),
        description: const Value(
          'Lie on your back with knees bent. Squeeze your glutes together tightly, hold for 5 seconds, then release. Focus on the contraction.',
        ),
        animationPath: const Value('assets/animations/level2/glute_squeezes.json'),
        setsReps: const Value('3x15'),
        durationSeconds: const Value(90),
        orderIndex: const Value(6),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Pelvic Circles'),
        description: const Value(
          'Stand with hands on hips. Make slow circles with your hips, moving clockwise then counterclockwise. Increases hip mobility.',
        ),
        animationPath: const Value('assets/animations/level2/pelvic_circles.json'),
        setsReps: const Value('2x10 each'),
        durationSeconds: const Value(90),
        orderIndex: const Value(7),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Transverse Abdominis Engagement'),
        description: const Value(
          'Lie on your back. Draw your belly button toward your spine without holding your breath. Hold for 10 seconds. This activates your deepest core muscles.',
        ),
        animationPath: const Value('assets/animations/level2/ta_engagement.json'),
        setsReps: const Value('3x10'),
        durationSeconds: const Value(90),
        orderIndex: const Value(8),
      ),
    ];

    await db.exerciseDao.insertMultipleExercises(exercises);
  }

  /// Level 3: Strengthen (12+ weeks) - 12 exercises, 20 min total
  static Future<void> _seedLevel3(AppDatabase db, int userId) async {
    final workoutId = await db.workoutDao.insertWorkout(
      WorkoutsCompanion(
        userId: Value(userId),
        level: const Value(3),
        name: const Value('Level 3: Strengthen'),
        description: const Value(
          'Advanced exercises to build strength, endurance, and power. For 12+ weeks postpartum.',
        ),
        durationMinutes: const Value(20),
        isCompleted: const Value(false),
      ),
    );

    final exercises = [
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Full Planks'),
        description: const Value(
          'Start in a push-up position. Hold your body in a straight line from head to heels. Keep core tight and don\'t let hips sag.',
        ),
        animationPath: const Value('assets/animations/level3/full_planks.json'),
        setsReps: const Value('3x30s'),
        durationSeconds: const Value(90),
        orderIndex: const Value(1),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Squats'),
        description: const Value(
          'Stand with feet shoulder-width apart. Lower down as if sitting back into a chair, keeping knees behind toes. Push through heels to stand.',
        ),
        animationPath: const Value('assets/animations/level3/squats.json'),
        setsReps: const Value('3x15'),
        durationSeconds: const Value(90),
        orderIndex: const Value(2),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Lunges'),
        description: const Value(
          'Step forward with one leg, lowering hips until both knees are bent at 90 degrees. Push back to start. Alternate legs.',
        ),
        animationPath: const Value('assets/animations/level3/lunges.json'),
        setsReps: const Value('3x12 each'),
        durationSeconds: const Value(120),
        orderIndex: const Value(3),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Mountain Climbers'),
        description: const Value(
          'Start in plank position. Bring one knee toward chest, then quickly switch legs. Keep core tight and hips level. Move quickly.',
        ),
        animationPath: const Value('assets/animations/level3/mountain_climbers.json'),
        setsReps: const Value('3x20'),
        durationSeconds: const Value(90),
        orderIndex: const Value(4),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Dead Bugs'),
        description: const Value(
          'Lie on back with arms up and knees bent at 90 degrees. Lower opposite arm and leg, keeping lower back on floor. Return and switch sides.',
        ),
        animationPath: const Value('assets/animations/level3/dead_bugs.json'),
        setsReps: const Value('3x12 each'),
        durationSeconds: const Value(90),
        orderIndex: const Value(5),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Modified Burpees'),
        description: const Value(
          'Squat down, place hands on ground. Step feet back to plank, step feet back in, stand up. No jumping required.',
        ),
        animationPath: const Value('assets/animations/level3/modified_burpees.json'),
        setsReps: const Value('3x10'),
        durationSeconds: const Value(90),
        orderIndex: const Value(6),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Jump Squats'),
        description: const Value(
          'Perform a squat, then explode up into a jump. Land softly and immediately go into next squat. Build power and explosiveness.',
        ),
        animationPath: const Value('assets/animations/level3/jump_squats.json'),
        setsReps: const Value('3x12'),
        durationSeconds: const Value(90),
        orderIndex: const Value(7),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Farmer Carries'),
        description: const Value(
          'Hold weights in each hand at your sides. Walk forward with good posture, keeping core engaged. Great for functional strength.',
        ),
        animationPath: const Value('assets/animations/level3/farmer_carries.json'),
        setsReps: const Value('3x30s'),
        durationSeconds: const Value(90),
        orderIndex: const Value(8),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Push-ups'),
        description: const Value(
          'Full push-ups from toes. Lower chest to ground, keeping body straight. Push back up. Modify on knees if needed.',
        ),
        animationPath: const Value('assets/animations/level3/pushups.json'),
        setsReps: const Value('3x12'),
        durationSeconds: const Value(90),
        orderIndex: const Value(9),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Pull-ups (Assisted)'),
        description: const Value(
          'Use resistance band or assisted pull-up machine. Pull body up until chin is over bar. Lower with control. Builds upper body strength.',
        ),
        animationPath: const Value('assets/animations/level3/assisted_pullups.json'),
        setsReps: const Value('3x8'),
        durationSeconds: const Value(90),
        orderIndex: const Value(10),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Running in Place'),
        description: const Value(
          'Run in place, bringing knees up high. Pump arms vigorously. Great cardio exercise to build endurance.',
        ),
        animationPath: const Value('assets/animations/level3/running_in_place.json'),
        setsReps: const Value('3x30s'),
        durationSeconds: const Value(90),
        orderIndex: const Value(11),
      ),
      ExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseName: const Value('Squat Jumps'),
        description: const Value(
          'Similar to jump squats but with more emphasis on height. Squat low, then jump as high as possible. Land softly in squat position.',
        ),
        animationPath: const Value('assets/animations/level3/squat_jumps.json'),
        setsReps: const Value('3x10'),
        durationSeconds: const Value(90),
        orderIndex: const Value(12),
      ),
    ];

    await db.exerciseDao.insertMultipleExercises(exercises);
  }
}
