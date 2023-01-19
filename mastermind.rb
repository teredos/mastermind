# frozen_string_literal: true

class Mastermind
  def initialize
    @game_code = []
    @num_of_guesses = 0
    @guess_digits = Array.new(12) { Array.new(4, '_') }
    @guess_results = Array.new(12) { Array.new(2, 0) }
    @cmp_found_digits_num = 0
    @cmp_found_digits = []
    pre_game
    new_game
  end

  def pre_game
    puts 'MASTERMIND'
    puts game_desc
    rules if read_rules?
  end

  def game_desc
    'A command-line variation of the popular board game Mastermind, using '\
      'digits instead of colours.'
  end

  def read_rules?
    sleep 1
    puts 'Would you like to read the rules? (Y/n)'
    rules_response = gets.chomp
    if ['Y', 'y', ''].include?(rules_response)
      true
    elsif %w[N n].include?(rules_response)
      false
    else
      puts 'Please only enter either Y or N (case insensitive).'
      read_rules?
    end
  end

  def rules
    sleep 1
    puts original_rules
    sleep 2
    puts variant_rules
    sleep 1
  end

  def original_rules
    "\nMastermind is a two-player game in which each player is assigned either"\
      ' the role of Codemaker or Codebreaker. The game begins with the '\
      'Codemaker creating a code with 4 consecutive code pegs, with each code '\
      'peg being one of 6 different colours. The Codebreaker then has 12 '\
      'guesses at cracking the code. After each guess, the Codemaker places '\
      'black or white pegs within 4 smaller holes next to the guess. Each '\
      'black peg signifies a correctly coloured and positioned peg in their '\
      'code and each white peg signifies a correctly coloured yet incorrectly'\
      ' positioned peg in their code. The Codebreaker wins the game if they '\
      "crack the code within 12 guesses and the Codemaker wins if they don't."
  end

  def variant_rules
    "\nThis command-line variation of Mastermind uses digits instead of "\
      'colours. Here, the code consists of 4 digits, with each digit being '\
      'between 1-6. The black and white pegs are replaced with a tick and '\
      'cross, and a number quantifying their occurrence.'
  end

  def new_game
    assign_roles
    case @user_role
    when 'Codemaker'
      create_user_code
      while @num_of_guesses != 12 && @guess_results.all? { |i| i[0] != 4 }
        receive_computer_guess
      end
    when 'Codebreaker'
      create_computer_code
      while @num_of_guesses != 12 && @guess_results.all? { |i| i[0] != 4 }
        receive_user_guess
      end
    end
    puts victor_message
    Mastermind.new if play_again?
  end

  def assign_roles
    if user_is_codemaker?
      puts "\nYou chose to be the Codemaker and so the Computer will play as "\
           'the Codebreaker.'
      @user_role = 'Codemaker'
    else
      puts "\nYou chose to be the Codebreaker and so the Computer will play as"\
           ' the Codemaker.'
      @user_role = 'Codebreaker'
    end
    sleep 1
  end

  def user_is_codemaker?
    puts "\nWould you like to play as the Codemaker? (Y/n)"
    role_response = gets.chomp
    if ['Y', 'y', ''].include?(role_response)
      true
    elsif %w[N n].include?(role_response)
      false
    else
      puts 'Please only enter either Y or N (case insensitive).'
      user_is_codemaker?
    end
  end

  def create_user_code
    puts "\nPlease enter a 4 digit code with numbers 1-6. You can use the "\
         'same digit more than once.'
    user_code = gets.chomp
    if user_code.length == 4 && user_code.chars.all? do |digit|
         (1..6).include?(digit.to_i)
       end
      user_code.chars.each { |digit| @game_code.push(digit.to_i) }
      puts "Your code is #{@game_code.join}. Let's see if the Computer can crack it!"
    else
      puts 'All codes must be 4 digits in length and only use the digits 1-6'
      create_user_code
    end
  end

  def create_computer_code
    4.times { @game_code.push(rand(1..6)) }
  end

  def receive_computer_guess
    puts "\nThe Computer is calculating its guess..."
    sleep 1
    if @num_of_guesses < 6 && @cmp_found_digits_num < 4
      @guess_digits[@num_of_guesses] = Array.new(4, @num_of_guesses + 1)
      update_results
      @cmp_found_digits_num += @guess_results[@num_of_guesses].sum
      if @guess_results[@num_of_guesses].sum != 0
        @guess_results[@num_of_guesses].sum.times do
          @cmp_found_digits.push(@num_of_guesses + 1)
        end
      end
    else
      cmp_found_digits_shuffle = @cmp_found_digits.shuffle
      while guess_used(cmp_found_digits_shuffle)
        cmp_found_digits_shuffle = @cmp_found_digits.shuffle
      end
      @guess_digits[@num_of_guesses] = cmp_found_digits_shuffle
      update_results
    end
    board
    @num_of_guesses += 1
  end

  def guess_used(guess)
    @guess_digits.any? { |i| i == guess }
  end

  def receive_user_guess
    puts "\nWhat is your guess?"
    user_guess_response = gets.chomp.chars.map(&:to_i)
    if guess_valid?(user_guess_response)
      @guess_digits[@num_of_guesses] = user_guess_response
      update_results
      board
      @num_of_guesses += 1
    else
      puts 'Please only submit a 4 digit guess with each number between 1-6.'
    end
  end

  def guess_valid?(guess)
    guess.all? { |num| num.between?(1, 6) } && guess.length == 4
  end

  def update_results
    current_game_code = @game_code.clone
    current_guess_code = @guess_digits[@num_of_guesses].clone
    i = 0
    j = 0
    while i != 4
      if @game_code[i] == @guess_digits[@num_of_guesses][i]
        @guess_results[@num_of_guesses][0] += 1
        current_game_code[i] = 0
        current_guess_code[i] = 0
      end
      i += 1
    end
    while j != 4
      if current_guess_code.include?(current_game_code[j]) && current_game_code[j] != 0
        @guess_results[@num_of_guesses][1] += 1
        current_guess_code[current_guess_code.find_index(current_game_code[j])] =
          0
        current_game_code[j] = 0
      end
      j += 1
    end
  end

  def board
    top_row
    guess_rows
  end

  def top_row
    puts "\n   Guesses      ✔ ✘"
  end

  def guess_rows
    12.times do |i|
      puts "   #{@guess_digits[i].join(' ')}      #{@guess_results[i].join(' ')}"
    end
  end

  def victor_message
    if @guess_results.any? { |i| i[0] == 4 }
      case @user_role
      when 'Codebreaker'
        "\nYou cracked the Computer's code. You win!"
      when 'Codemaker'
        "\nThe Computer cracked your code. The Computer wins!"
      end
    elsif @num_of_guesses == 12
      case @user_role
      when 'Codebreaker'
        "\nYou failed to crack the Computer's code. The Computer wins!"
      when 'Codemaker'
        "\nThe Computer failed to crack your code. You win!"
      end
    end
  end

  def play_again?
    puts "\nWould you like to play again? (Y/n)"
    new_game_response = gets.chomp
    if ['Y', 'y', ''].include?(new_game_response)
      true
    elsif %w[N n].include?(new_game_response)
      false
    else
      puts 'Please only enter either Y or N (case insensitive).'
      play_again?
    end
  end
end

Mastermind.new
