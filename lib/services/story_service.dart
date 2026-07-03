import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story_model.dart';
import '../models/reading_progress_model.dart';


class StoryService {
  static final StoryService _instance = StoryService._internal();
  factory StoryService() => _instance;
  StoryService._internal();

  static const String _favsKey = 'reading_favorites';
  static const String _progressKey = 'reading_progress';
  static const String _coinsKey = 'user_coins';
  static const String _streakKey = 'user_streak';
  static const String _streakDateKey = 'user_streak_date';

  // ── Predefined list of 20 educational stories ──────────────────────────────
  final List<Story> _stories = [
    Story(
      id: '1',
      title: 'The Thirsty Crow',
      thumbnailPath: '🐦',
      difficulty: Difficulty.beginner,
      readingTimeMinutes: 2,
      category: 'Moral Tales',
      sentences: [
        'A thirsty crow flew all over the fields looking for water.',
        'For a long time, he could not find any.',
        'He felt very weak and thought he would die.',
        'Suddenly, he saw a water pitcher below him.',
        'He flew straight down to see if there was water inside.',
        'Yes, he could see some water inside the pitcher!',
        'But the pitcher was high and its neck was narrow.',
        'No matter how hard he tried, he could not reach the water.',
        'Then he saw some small stones lying on the ground.',
        'He picked up the stones one by one and dropped them into the pitcher.',
        'As more stones fell in, the water level rose to the top.',
        'The clever crow drank the water and flew away happily.'
      ],
      quizQuestions: [
        {
          'question': 'What was the crow looking for?',
          'options': ['Food', 'Water', 'A nest', 'Friends'],
          'correctOptionIndex': 1
        },
        {
          'question': 'Why could the crow not drink the water at first?',
          'options': [
            'The water was dirty',
            'The pitcher was too small',
            'The pitcher neck was narrow and deep',
            'Another bird drank it'
          ],
          'correctOptionIndex': 2
        },
        {
          'question': 'How did the crow raise the water level?',
          'options': [
            'By tipping the pitcher',
            'By dropping stones inside',
            'By calling for rain',
            'By using a straw'
          ],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '2',
      title: 'The Lion and the Mouse',
      thumbnailPath: '🦁',
      difficulty: Difficulty.beginner,
      readingTimeMinutes: 2,
      category: 'Animal Stories',
      sentences: [
        'A great lion was sleeping peacefully in the forest.',
        'A tiny mouse began running up and down his back for fun.',
        'This woke up the angry lion, who placed his huge paw on the mouse.',
        'Please spare me, cried the little mouse.',
        'If you let me go, I will help you one day.',
        'The lion laughed at the idea of a mouse helping a king, but let him go.',
        'A few days later, the lion was caught in a hunter\'s strong net.',
        'He roared loudly, unable to free himself.',
        'The little mouse heard the roar and ran to the spot.',
        'He used his sharp teeth to gnaw through the thick ropes.',
        'Soon, the lion was free and thanked the tiny mouse.'
      ],
      quizQuestions: [
        {
          'question': 'Who woke up the sleeping lion?',
          'options': ['A hunter', 'A tiny mouse', 'A bird', 'A monkey'],
          'correctOptionIndex': 1
        },
        {
          'question': 'Why did the lion laugh at the mouse?',
          'options': [
            'Because the mouse was funny',
            'Because the mouse was tiny and promised to help him',
            'Because the mouse sang a song',
            'Because the mouse danced'
          ],
          'correctOptionIndex': 1
        },
        {
          'question': 'How did the mouse help the lion escape?',
          'options': [
            'By calling other lions',
            'By chewing the hunter\'s net',
            'By distracting the hunter',
            'By digging a hole'
          ],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '3',
      title: 'The Hare and the Tortoise',
      thumbnailPath: '🐢',
      difficulty: Difficulty.beginner,
      readingTimeMinutes: 2,
      category: 'Fables',
      sentences: [
        'A speedy hare was always boasting about how fast he could run.',
        'Tired of his boasting, the slow tortoise challenged him to a race.',
        'The hare laughed and accepted, confident he would win easily.',
        'The race began, and the hare shot ahead, leaving the tortoise far behind.',
        'Seeing the tortoise slow pace, the hare decided to take a nap under a shady tree.',
        'He quickly fell fast asleep in the cool breeze.',
        'Meanwhile, the tortoise kept walking slowly but steadily.',
        'He did not stop for a single moment.',
        'When the hare woke up, he saw the tortoise just crossing the finish line.',
        'The slow and steady tortoise had won the race!'
      ],
      quizQuestions: [
        {
          'question': 'Who did the hare boast to?',
          'options': ['The fox', 'The tortoise', 'The bird', 'The bear'],
          'correctOptionIndex': 1
        },
        {
          'question': 'What did the hare do during the race?',
          'options': ['Ate carrots', 'Took a nap', 'Got lost', 'Helped others'],
          'correctOptionIndex': 1
        },
        {
          'question': 'What is the moral of the story?',
          'options': [
            'Speed is everything',
            'Slow and steady wins the race',
            'Never run on hot days',
            'Do not play in the forest'
          ],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '4',
      title: 'The Boy Who Cried Wolf',
      thumbnailPath: '🐺',
      difficulty: Difficulty.beginner,
      readingTimeMinutes: 2,
      category: 'Moral Tales',
      sentences: [
        'A shepherd boy watched his sheep on the hillside every day.',
        'He was often lonely and felt very bored.',
        'To have some fun, he ran down to the village shouting, Wolf! Wolf!',
        'The kind villagers dropped their work and ran up the hill to save the sheep.',
        'When they arrived, they found no wolf, and the boy laughed at them.',
        'A few days later, the boy played the same trick again.',
        'Once more, the villagers ran up and were angry to be fooled twice.',
        'Then, one evening, a real wolf came out from the forest.',
        'Terrified, the boy screamed for help, Wolf! Wolf! Please help!',
        'But the villagers thought he was lying again and stayed in their homes.',
        'The wolf ate many of the sheep, and the boy wept in regret.'
      ],
      quizQuestions: [
        {
          'question': 'Why did the boy cry "Wolf!" at first?',
          'options': [
            'He saw a real wolf',
            'He was bored and wanted attention',
            'He wanted to feed the sheep',
            'He lost his way'
          ],
          'correctOptionIndex': 1
        },
        {
          'question': 'Why did the villagers not help the boy the last time?',
          'options': [
            'They were sleeping',
            'They did not hear him',
            'They thought he was lying again',
            'They were afraid of the wolf'
          ],
          'correctOptionIndex': 2
        },
        {
          'question': 'What happens when a liar tells the truth?',
          'options': [
            'People believe them',
            'People do not believe them',
            'They get a reward',
            'They learn to run fast'
          ],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '5',
      title: 'The Fox and the Grapes',
      thumbnailPath: '🦊',
      difficulty: Difficulty.beginner,
      readingTimeMinutes: 2,
      category: 'Fables',
      sentences: [
        'A hungry fox sneaked into a vineyard on a warm afternoon.',
        'He saw big, juicy purple grapes hanging high on a vine.',
        'His mouth watered as he looked at them.',
        'He took a few steps back, leaped high into the air, but missed.',
        'He tried again and again, jumping as high as he could.',
        'Still, the grapes remained just out of his reach.',
        'Finally, tired and disappointed, the fox walked away.',
        'He shook his head and said, They are probably sour anyway.'
      ],
      quizQuestions: [
        {
          'question': 'What did the fox want to eat?',
          'options': ['Apples', 'Grapes', 'Berries', 'Cheese'],
          'correctOptionIndex': 1
        },
        {
          'question': 'Why could the fox not get the grapes?',
          'options': [
            'They were locked',
            'They were hanging too high',
            'A guard stopped him',
            'They fell on the floor'
          ],
          'correctOptionIndex': 1
        },
        {
          'question': 'What did the fox say when he failed?',
          'options': [
            'The grapes are sweet',
            'The grapes are sour',
            'I will return tomorrow',
            'I will call my friends'
          ],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '6',
      title: 'The Ant and the Grasshopper',
      thumbnailPath: '🐜',
      difficulty: Difficulty.intermediate,
      readingTimeMinutes: 3,
      category: 'Fables',
      sentences: [
        'On a warm summer day, a grasshopper was hopping and singing merrily.',
        'He saw an ant walking past, carrying a heavy grain of corn to her nest.',
        'Why work so hard? asked the grasshopper. Come, sing with me instead.',
        'I am storing food for winter, replied the wise ant.',
        'The grasshopper laughed and said, We have plenty of food right now.',
        'The ant ignored him and continued her hard work.',
        'When winter arrived, the fields were covered in thick snow.',
        'The grasshopper had no food and was freezing and hungry.',
        'He walked to the ant\'s warm nest and asked for some food.',
        'The ant shook her head and said, If you sang all summer, you can dance all winter!'
      ],
      quizQuestions: [
        {
          'question': 'What was the ant doing in summer?',
          'options': ['Singing', 'Storing food', 'Sleeping', 'Playing games'],
          'correctOptionIndex': 1
        },
        {
          'question': 'What did the grasshopper do in summer?',
          'options': ['Worked hard', 'Sang and relaxed', 'Built a nest', 'Traveled'],
          'correctOptionIndex': 1
        },
        {
          'question': 'What happened to the grasshopper in winter?',
          'options': [
            'He was warm and cozy',
            'He had no food and was hungry',
            'He went to the beach',
            'He found a garden'
          ],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '7',
      title: 'Goldilocks & the Three Bears',
      thumbnailPath: '🐻',
      difficulty: Difficulty.intermediate,
      readingTimeMinutes: 3,
      category: 'Fairy Tales',
      sentences: [
        'A little girl named Goldilocks went for a walk in the forest.',
        'She came across a pretty cottage belonging to three bears.',
        'Since the door was open, she walked inside.',
        'On the table, there were three bowls of warm porridge.',
        'She tasted the largest bowl, but it was too hot.',
        'She tasted the middle bowl, but it was too cold.',
        'Finally, she tasted the smallest bowl, and it was just right, so she ate it all.',
        'Then, she sat on the smallest chair, but it broke under her weight.',
        'Feeling tired, she went upstairs and fell asleep in the smallest bed.',
        'When the bears returned, they noticed the eaten porridge and the broken chair.',
        'They went upstairs and saw Goldilocks sleeping peacefully.',
        'Goldilocks woke up, saw the bears, screamed in fear, and ran away.'
      ],
      quizQuestions: [
        {
          'question': 'Whose house did Goldilocks enter?',
          'options': ['Three rabbits', 'Three bears', 'A witch', 'Her grandma'],
          'correctOptionIndex': 1
        },
        {
          'question': 'Which bowl of porridge did she finish?',
          'options': ['The hot one', 'The cold one', 'The smallest, just right one', 'None of them'],
          'correctOptionIndex': 2
        },
        {
          'question': 'What happened to the smallest chair?',
          'options': ['It was stolen', 'It broke', 'It painted blue', 'She slept on it'],
          'correctOptionIndex': 1
        }
      ]
    ),
    // 13 more simple stories pre-packaged for children 4-14
    Story(
      id: '8',
      title: 'Little Red Riding Hood',
      thumbnailPath: '🐺',
      difficulty: Difficulty.intermediate,
      readingTimeMinutes: 3,
      category: 'Fairy Tales',
      sentences: [
        'Little Red Riding Hood went to visit her sick grandmother in the woods.',
        'Her mother warned her to stay on the path and not talk to strangers.',
        'On the way, she met a clever wolf who asked where she was going.',
        'She politely told him she was heading to her grandmother\'s cottage.',
        'The wolf ran ahead and arrived at the cottage first.',
        'He dressed up as the grandmother and jumped into her bed.',
        'When the girl arrived, she noticed her grandmother looked very strange.',
        'What big ears and teeth you have! she cried.',
        'All the better to eat you with! roared the wolf.',
        'Fortunately, a brave woodcutter heard her scream and rescued them both.'
      ],
      quizQuestions: [
        {
          'question': 'Who was Red Riding Hood visiting?',
          'options': ['Her aunt', 'Her grandmother', 'Her friend', 'Her teacher'],
          'correctOptionIndex': 1
        },
        {
          'question': 'Who saved them from the wolf?',
          'options': ['A hunter', 'A woodcutter', 'Her father', 'The police'],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '9',
      title: 'The Ugly Duckling',
      thumbnailPath: '🦆',
      difficulty: Difficulty.intermediate,
      readingTimeMinutes: 3,
      category: 'Moral Tales',
      sentences: [
        'A mother duck was surprised when one of her eggs hatched into a large grey duckling.',
        'The other farm animals teased him because he looked different and plain.',
        'Sad and lonely, the duckling ran away from the farm.',
        'He spent a cold, hard winter hiding in the reeds of a marsh.',
        'When spring came, he saw a group of beautiful white swans swimming.',
        'He bowed his head, expecting them to tease him too.',
        'But looking at his reflection in the clear water, he saw a beautiful swan!',
        'He was no longer an ugly duckling, but a proud and elegant swan.'
      ],
      quizQuestions: [
        {
          'question': 'Why was the duckling teased?',
          'options': ['He was too small', 'He looked different and grey', 'He could not swim', 'He was loud'],
          'correctOptionIndex': 1
        },
        {
          'question': 'What did he grow up to be?',
          'options': ['A goose', 'A chicken', 'A beautiful swan', 'An eagle'],
          'correctOptionIndex': 2
        }
      ]
    ),
    Story(
      id: '10',
      title: 'The Honest Woodcutter',
      thumbnailPath: '🪓',
      difficulty: Difficulty.intermediate,
      readingTimeMinutes: 3,
      category: 'Moral Tales',
      sentences: [
        'A poor woodcutter was chopping wood near a deep river.',
        'His iron axe accidentally slipped from his hands and fell into the water.',
        'He sat by the bank and wept because he had lost his only tool.',
        'A water fairy appeared, dove into the river, and brought up a golden axe.',
        'Is this yours? she asked. No, replied the honest woodcutter.',
        'She dove again and brought up a silver axe. No, that is not mine either, he said.',
        'Finally, she brought up his old iron axe. Yes, that is mine! he cried.',
        'Impressed by his honesty, the fairy gave him all three axes as a reward.'
      ],
      quizQuestions: [
        {
          'question': 'What did the woodcutter drop in the river?',
          'options': ['His coins', 'His iron axe', 'His shoes', 'A log'],
          'correctOptionIndex': 1
        },
        {
          'question': 'Why did the fairy reward him with all three axes?',
          'options': ['He was strong', 'He was honest', 'He could swim well', 'He was rich'],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '11',
      title: 'The Goose with the Golden Eggs',
      thumbnailPath: '🪿',
      difficulty: Difficulty.beginner,
      readingTimeMinutes: 2,
      category: 'Moral Tales',
      sentences: [
        'A farmer had a wonderful goose that laid one golden egg every day.',
        'This made the farmer very rich and comfortable.',
        'But the farmer grew greedy and wanted to get all the gold at once.',
        'He decided to kill the goose to take all the eggs from inside her.',
        'When he cut the goose open, he found she was just like any other goose.',
        'He got no gold and lost his valuable source of daily wealth.'
      ],
      quizQuestions: [
        {
          'question': 'What kind of egg did the goose lay?',
          'options': ['Silver', 'Golden', 'Bronze', 'Normal'],
          'correctOptionIndex': 1
        },
        {
          'question': 'What was the farmer\'s mistake?',
          'options': ['He sold the goose', 'He was greedy and killed the goose', 'He forgot to feed it', 'He lost the eggs'],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '12',
      title: 'The Clever Monkey',
      thumbnailPath: '🐒',
      difficulty: Difficulty.intermediate,
      readingTimeMinutes: 3,
      category: 'Animal Stories',
      sentences: [
        'A clever monkey lived on a berry tree near a river bank.',
        'A crocodile visited him often, and the monkey shared sweet berries with him.',
        'The crocodile\'s wife wanted to eat the sweet monkey\'s heart.',
        'The crocodile agreed and invited the monkey to his home for dinner.',
        'He carried the monkey on his back across the deep river.',
        'In the middle of the river, the crocodile revealed his true plan.',
        'The monkey did not panic. He said, I left my heart back on the tree!',
        'The foolish crocodile swam back to the bank immediately.',
        'The monkey jumped onto the tree and saved his life.'
      ],
      quizQuestions: [
        {
          'question': 'Where did the monkey live?',
          'options': ['In a cave', 'On a berry tree', 'In the river', 'On a mountain'],
          'correctOptionIndex': 1
        },
        {
          'question': 'How did the monkey escape?',
          'options': ['By swimming fast', 'By tricking the crocodile', 'By calling a bird', 'By throwing stones'],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '13',
      title: 'The Wind and the Sun',
      thumbnailPath: '☀️',
      difficulty: Difficulty.beginner,
      readingTimeMinutes: 2,
      category: 'Fables',
      sentences: [
        'The Wind and the Sun had an argument about who was stronger.',
        'They saw a traveler walking down the road wearing a warm coat.',
        'Let\'s see who can make him take off his coat, they agreed.',
        'The Wind blew hard and cold, but the traveler pulled his coat closer.',
        'Then the Sun shone gently, making the air warm and bright.',
        'The traveler felt hot, smiled, and took off his coat.',
        'Gentle warmth succeeded where force could not.'
      ],
      quizQuestions: [
        {
          'question': 'What was the challenge?',
          'options': ['To blow a tree down', 'To make the traveler take off his coat', 'To cross the river', 'To climb the hill'],
          'correctOptionIndex': 1
        },
        {
          'question': 'Who won the contest?',
          'options': ['The Wind', 'The Sun', 'The traveler', 'Both'],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '14',
      title: 'The Dog and his Shadow',
      thumbnailPath: '🐕',
      difficulty: Difficulty.beginner,
      readingTimeMinutes: 2,
      category: 'Animal Stories',
      sentences: [
        'A dog found a juicy piece of meat and was carrying it home.',
        'He walked across a narrow bridge over a clear stream.',
        'He looked down and saw his own reflection in the water.',
        'He thought it was another dog with a larger piece of meat.',
        'Greedy to get it, he opened his mouth and barked loudly.',
        'The moment he did, his own meat fell into the stream and sank.'
      ],
      quizQuestions: [
        {
          'question': 'What did the dog see in the water?',
          'options': ['Another dog', 'His own reflection', 'A fish', 'A stone'],
          'correctOptionIndex': 1
        },
        {
          'question': 'Why did he lose his meat?',
          'options': ['He dropped it while running', 'He barked out of greed', 'A cat stole it', 'It was too heavy'],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '15',
      title: 'The Magic Paintbrush',
      thumbnailPath: '🖌️',
      difficulty: Difficulty.advanced,
      readingTimeMinutes: 4,
      category: 'Folk Tales',
      sentences: [
        'A poor boy named Ma Liang loved to draw but could not afford a brush.',
        'One night, an old man gave him a beautiful magic paintbrush.',
        'Whatever Ma Liang painted with it came to life instantly!',
        'He painted food for the hungry and water pumps for dry fields.',
        'A greedy king heard of this and captured the boy.',
        'He forced Ma Liang to paint a huge mountain of gold.',
        'Ma Liang painted the gold mountain on an island in the blue sea.',
        'Then he painted a large wooden ship for the king to sail there.',
        'As the king sailed, Ma Liang painted a fierce wind storm.',
        'The waves sank the ship, and the greedy king was never seen again.'
      ],
      quizQuestions: [
        {
          'question': 'What did the magic paintbrush do?',
          'options': ['Color by itself', 'Make drawings come to life', 'Write stories', 'Sparkle'],
          'correctOptionIndex': 1
        },
        {
          'question': 'What did the king force the boy to paint?',
          'options': ['A castle', 'A mountain of gold', 'A horse', 'A crown'],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '16',
      title: 'The Peacock and the Crane',
      thumbnailPath: '🦚',
      difficulty: Difficulty.beginner,
      readingTimeMinutes: 2,
      category: 'Animal Stories',
      sentences: [
        'A proud peacock always mocked a simple crane for her plain feathers.',
        'Look at my colorful, shining feathers! boasted the peacock.',
        'You look so dull and grey compared to me.',
        'The crane smiled, spread her wings, and flew high into the sky.',
        'I can fly high among the clouds, she called down.',
        'You can only walk on the dirty ground with your pretty feathers.'
      ],
      quizQuestions: [
        {
          'question': 'Who had plain feathers?',
          'options': ['The peacock', 'The crane', 'The parrot', 'The owl'],
          'correctOptionIndex': 1
        },
        {
          'question': 'What could the crane do that the peacock could not?',
          'options': ['Sing sweetly', 'Fly high in the sky', 'Run fast', 'Swim'],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '17',
      title: 'The Ant and the Dove',
      thumbnailPath: '🕊️',
      difficulty: Difficulty.beginner,
      readingTimeMinutes: 2,
      category: 'Animal Stories',
      sentences: [
        'A tiny ant slipped and fell into a fast-flowing river.',
        'A kind dove sitting on a branch plucked a leaf and dropped it nearby.',
        'The ant climbed onto the leaf and floated safely to the dry bank.',
        'Just then, a hunter was about to throw a net over the sleeping dove.',
        'The ant saw this and bit the hunter hard on his heel.',
        'The hunter cried out in pain, dropping the net.',
        'The noise woke the dove, who quickly flew away to safety.'
      ],
      quizQuestions: [
        {
          'question': 'Who saved the ant from drowning?',
          'options': ['The fish', 'The dove', 'A frog', 'A mouse'],
          'correctOptionIndex': 1
        },
        {
          'question': 'How did the ant save the dove?',
          'options': ['By screaming', 'By biting the hunter', 'By calling friends', 'By flying'],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '18',
      title: 'The Lion and the Three Bulls',
      thumbnailPath: '🐂',
      difficulty: Difficulty.advanced,
      readingTimeMinutes: 4,
      category: 'Fables',
      sentences: [
        'Three strong bulls grazed together in a green pasture.',
        'Whenever a hungry lion tried to attack them, they stood tail-to-tail.',
        'Their sharp horns pointed outward in all directions, keeping them safe.',
        'The lion realized he could not defeat them while they were united.',
        'He began whispering lies and rumors to each bull about the others.',
        'Soon, the bulls quarreled, stopped speaking, and grazed in separate corners.',
        'One by one, the lion attacked the isolated bulls and ate them easily.',
        'Unity is strength; division leads to defeat.'
      ],
      quizQuestions: [
        {
          'question': 'Why were the bulls safe at first?',
          'options': ['They ran fast', 'They stood united tail-to-tail', 'They had a fence', 'They were fast sleeping'],
          'correctOptionIndex': 1
        },
        {
          'question': 'How did the lion defeat the bulls?',
          'options': ['With helper animals', 'By dividing them with rumors', 'By digging traps', 'By using magic'],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '19',
      title: 'The Greedy Boy',
      thumbnailPath: '🍬',
      difficulty: Difficulty.beginner,
      readingTimeMinutes: 2,
      category: 'Moral Tales',
      sentences: [
        'A boy was offered a jar filled with sweet candies.',
        'He reached in and grabbed a huge handful, filling his fist completely.',
        'But the neck of the jar was very small and narrow.',
        'He could not pull his closed fist out of the jar.',
        'He started crying because he did not want to lose any candy.',
        'His mother smiled and said, Just take half, and your hand will come out.',
        'He let go of some candies, pulled his hand out easily, and felt happy.'
      ],
      quizQuestions: [
        {
          'question': 'Why could the boy not pull his hand out?',
          'options': ['His hand was sticky', 'The jar neck was narrow and his fist was full', 'The jar was heavy', 'His hand got hurt'],
          'correctOptionIndex': 1
        },
        {
          'question': 'What was the mother\'s advice?',
          'options': ['Break the jar', 'Take less candy', 'Call your father', 'Don\'t eat candy'],
          'correctOptionIndex': 1
        }
      ]
    ),
    Story(
      id: '20',
      title: 'The Fox and the Crow',
      thumbnailPath: '🧀',
      difficulty: Difficulty.intermediate,
      readingTimeMinutes: 3,
      category: 'Fables',
      sentences: [
        'A crow was sitting on a high branch with a tasty piece of cheese in her beak.',
        'A hungry fox saw her and wanted the cheese for himself.',
        'He stood under the tree and began praising the crow\'s beauty.',
        'What shiny feathers and lovely eyes you have! he exclaimed.',
        'I am sure your voice is as beautiful as your feathers. Please sing a song!',
        'Flattered, the crow opened her beak wide to sing, Caw! Caw!',
        'The cheese fell instantly from her mouth, and the fox caught it and ate it.',
        'Never trust flatterers who praise you for their own gain.'
      ],
      quizQuestions: [
        {
          'question': 'What did the crow hold in her beak?',
          'options': ['A leaf', 'A piece of cheese', 'A stone', 'A grape'],
          'correctOptionIndex': 1
        },
        {
          'question': 'Why did the crow open her mouth?',
          'options': ['To eat the cheese', 'To sing a song', 'To drink water', 'To call friends'],
          'correctOptionIndex': 1
        }
      ]
    ),
  ];

  List<Story> get stories => _stories;

  // ── Favorites management ──────────────────────────────────────────────────
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favsKey) ?? [];
  }

  Future<void> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_favsKey) ?? [];
    if (favs.contains(id)) {
      favs.remove(id);
    } else {
      favs.add(id);
    }
    await prefs.setStringList(_favsKey, favs);
  }

  // ── Reading Progress management ──────────────────────────────────────────────
  Future<ReadingProgress?> getReadingProgress(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final mapStr = prefs.getString(_progressKey) ?? '{}';
    final Map<String, dynamic> map = jsonDecode(mapStr);
    if (!map.containsKey(storyId)) return null;
    return ReadingProgress.fromJson(map[storyId] as Map<String, dynamic>);
  }

  Future<void> saveReadingProgress(ReadingProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final mapStr = prefs.getString(_progressKey) ?? '{}';
    final Map<String, dynamic> map = jsonDecode(mapStr);
    map[progress.storyId] = progress.toJson();
    await prefs.setString(_progressKey, jsonEncode(map));
  }

  Future<int> getProgress(String storyId) async {
    final progress = await getReadingProgress(storyId);
    return progress?.lastSentenceIndex ?? 0;
  }

  Future<void> saveProgress(String storyId, int index) async {
    final progress = ReadingProgress(
      storyId: storyId,
      lastSentenceIndex: index,
      percentComplete: 0.0, // simplified percent complete calculation
      lastUpdated: DateTime.now(),
    );
    await saveReadingProgress(progress);
  }


  // ── Coins and Streaks ──────────────────────────────────────────────────────
  Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 0;
  }

  Future<void> addCoins(int amt) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_coinsKey) ?? 0;
    await prefs.setInt(_coinsKey, current + amt);
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_streakDateKey) ?? '';
    if (lastDate != today) {
      final currentStreak = prefs.getInt(_streakKey) ?? 0;
      await prefs.setInt(_streakKey, currentStreak + 1);
      await prefs.setString(_streakDateKey, today);
    }
  }
}
