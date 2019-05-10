# frozen_string_literal: true
require 'parslet'

module Scim
  module Kit
    module V2
=begin
FILTER    = attrExp / logExp / valuePath / *1"not" "(" FILTER ")"

valuePath = attrPath "[" valFilter "]"
           ; FILTER uses sub-attributes of a parent attrPath

valFilter = attrExp / logExp / *1"not" "(" valFilter ")"

attrExp   = (attrPath SP "pr") /
           (attrPath SP compareOp SP compValue)

logExp    = FILTER SP ("and" / "or") SP FILTER

compValue = false / null / true / number / string
           ; rules from JSON (RFC 7159)

compareOp = "eq" / "ne" / "co" /
                  "sw" / "ew" /
                  "gt" / "lt" /
                  "ge" / "le"

attrPath  = [URI ":"] ATTRNAME *1subAttr
           ; SCIM attribute name
           ; URI is SCIM "schema" URI

ATTRNAME  = ALPHA *(nameChar)

nameChar  = "-" / "_" / DIGIT / ALPHA

subAttr   = "." ATTRNAME
           ; a sub-attribute of a complex attribute
=end
      class Parser < Parslet::Parser
        root :filter
        rule(:filter) do
          (attribute_expression | logical_expression | value_path) |
            (not_op? >> lparen >> filter >> rparen)
        end
        rule(:value_path) do
          attribute_path >> lbracket >> value_filter >> rbracket
        end
        rule(:value_filter) do
          attribute_expression |
            logical_expression |
            (not_op? >> lparen >> value_filter >> rparen)
        end
        rule(:attribute_expression) do
          (attribute_path >> space >> presence) |
            (attribute_path >> space >> comparison_operator >> space >> quote >> comparison_value >> quote)
        end
        rule(:logical_expression) do
          filter >> space >> (and_op | or_op) >> space >> filter
        end
        rule(:comparison_value) do
          (falsey | null | truthy | number | string | scim_schema_uri).repeat(1)
        end
        rule(:comparison_operator) do
          equal | not_equal | contains | starts_with | ends_with |
            greater_than | less_than | less_than_equals | greater_than_equals
        end
        rule(:attribute_path) { scim_schema_uri | attribute_name >> sub_attribute.maybe }
        rule(:attribute_name) { alpha >> name_character.repeat(1) }
        rule(:name_character) { hyphen | underscore | digit | alpha }
        rule(:sub_attribute) { dot >> attribute_name }
        rule(:presence) { str('pr') }
        rule(:and_op) { str('and') }
        rule(:or_op) { str('or') }
        rule(:not_op) { str('not') }
        rule(:not_op?) { not_op.maybe }
        rule(:falsey) { str('false') }
        rule(:truthy) { str('true') }
        rule(:null) { str('null') }
        rule(:number) { digit.repeat(1) }
        rule(:scim_schema_uri) { (alpha | digit | dot | colon).repeat(1) }
        rule(:equal) { str("eq") }
        rule(:not_equal) { str("ne") }
        rule(:contains) { str("co") }
        rule(:starts_with) { str("sw") }
        rule(:ends_with) { str("ew") }
        rule(:greater_than) { str("gt") }
        rule(:less_than) { str("lt") }
        rule(:greater_than_equals) { str("ge") }
        rule(:less_than_equals) { str("le") }
        rule(:string) { (alpha | single_quote).repeat(1) }
        rule(:lparen) { str('(') >> space? }
        rule(:rparen) { str(')') >> space? }
        rule(:lbracket) { str('[') >> space? }
        rule(:rbracket) { str(']') >> space? }
        rule(:digit) { match(/\d/) }
        rule(:quote) { str('"') }
        rule(:single_quote) { str("'") }
        rule(:space) { match('\s') }
        rule(:space?) { space.maybe }
        rule(:alpha) { match('[a-zA-Z]') }
        rule(:dot) { str('.') }
        rule(:colon) { str(':') }
        rule(:hyphen) { str('-') }
        rule(:underscore) { str('_') }
      end
    end
  end
end
