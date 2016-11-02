module Ingreedy
  class RootParser < Parslet::Parser
    rule(:range) do
      AmountParser.new.as(:amount) >>
        whitespace.maybe >>
        range_separator >>
        whitespace.maybe >>
        AmountParser.new.as(:amount_end)
    end

    rule(:range_separator) do
      str("-") | str("~")
    end

    rule(:amount) do
      AmountParser.new.as(:amount)
    end

    rule(:whitespace) do
      match("\s")
    end

    rule(:container_amount) do
      AmountParser.new
    end

    rule(:unit) do
      if unit_matches.any?
        unit_matches.map { |u| str(u) }.inject(:|)
      else
        str("")
      end
    end

    rule(:container_unit) do
      unit
    end

    rule(:unit_and_preposition) do
      unit.as(:unit) >> (preposition_or_whitespace | any.absent?)
    end

    rule(:preposition_or_whitespace) do
      if prepositions.empty?
        whitespace
      else
        preposition | whitespace
      end
    end

    rule(:preposition) do
      whitespace >>
        prepositions.map { |con| str(con) }.inject(:|) >>
        whitespace
    end

    rule(:amount_unit_separator) do
      whitespace | str("-")
    end

    rule(:container_size) do
      # e.g. (12 ounce) or 12 ounce
      str("(").maybe >>
        container_amount.as(:container_amount) >>
        amount_unit_separator.maybe >>
        container_unit.as(:container_unit) >>
        str(")").maybe >> preposition_or_whitespace
    end

    rule(:amount_and_unit) do
      (range | amount) >>
        whitespace.maybe >>
        unit_and_preposition.maybe >>
        container_size.maybe
    end

    rule(:quantity) do
      amount_and_unit | unit_and_preposition
    end

    rule(:space)      { match('\s').repeat(1) }
    rule(:space?)     { space.maybe }
    #
    # rule(:detail) do
    #   str(", ").maybe >>
    #       match['[:alnum:]'].repeat(1).as(:detail)
    # end

    rule(:name) { str(', ').maybe >> match['[:alnum:]'].repeat >> str(', ').maybe }



    rule(:spaces) { match('\s').repeat(1) }
    # at least 1 space character (space, tab, new line, carriage return)

    rule(:spaces?) { spaces.maybe }
    # a bunch of spaces or not


    rule(:comma) { spaces? >> str(',') >> spaces? }

    rule(:value) {
      phrase  |
          array
    }


    rule(:array) {
      str('(') >> spaces? >>
          (value >> (comma >> value).repeat).maybe.as(:detail) >>
          spaces? >> str(')')
    }


    rule(:names) {

      whitespace.maybe >>

          str('(').maybe >>
          str(', ').maybe >>
          (match['[:alnum:]'] >>
              (str(', ').maybe >>
                  space? >>
                  phrase >>
                  space?).repeat.maybe).maybe.as(:detail) >>
          str(')').maybe
    }



    rule(:phrase) do
      whitespace.maybe >> match['[:alnum:]'] >> whitespace.maybe >> match("[-!/&]").maybe
    end

    rule(:ingredient) do
      whitespace.maybe >> phrase.repeat.as(:ingredient) >> whitespace.maybe
    end

    rule(:standard_format) do
      # e.g. 1/2 (12 oz) can black beans

      quantity.maybe >> ingredient >> names.maybe >> array.maybe
    end


    rule(:reverse_format) do
      # e.g. flour 200g
      ((whitespace >> quantity).absent? >> any).repeat.as(:ingredient) >>
        whitespace >>
        quantity
    end

    rule(:ingredient_addition) do
      standard_format | reverse_format
    end

    root :ingredient_addition

    def initialize(original_query)
      @original_query = original_query
    end

    def parse
      super(original_query)
    end

    private

    attr_reader :original_query

    def prepositions
      Ingreedy.dictionaries.current.prepositions
    end

    def unit_matches
      @unit_matches ||= original_query.
                        scan(UnitVariationMapper.regexp).
                        sort_by(&:length).
                        reverse
    end
  end
end
