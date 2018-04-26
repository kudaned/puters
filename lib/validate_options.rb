class ValidateOptions

  def initialize(env, search_term)
    @any_errors = false
    @env = env
    @search_term = search_term
    @envs = ['dev', 'qa', 'prod']

    validate
  end

  def validate
    errors = []

    # Check for errors
    errors << '- Environment entry is incorrect' unless @envs.include? @env
    errors << '- Search term is blank' if @search_term.nil?

    unless errors.empty?
      puts 'Please fix the following:'
      errors.map { |e| puts e }
      @any_errors = true
    end
  end

  def has_errors
    @any_errors
  end

end

