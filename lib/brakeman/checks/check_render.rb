require 'brakeman/checks/base_check'

#Check calls to +render()+ for dangerous values
class Brakeman::CheckRender < Brakeman::BaseCheck
  Brakeman::Checks.add self

  @description = "Finds calls to render that might allow file access"

  def check_expr(var, expr, a_class, a_method)
    binding.pry
    return unless expr
    if expr[0]    == :call &&
      (
       (expr[1] && expr[1][0] == :lvar && expr[1][1] == var) ||
       expr[1].to_s =~ /s\(:lvar, :#{var}\)/
      )
       expr[2]    == :<<

      #binding.pry

      if input = include_user_input?(expr[3])
        confidence = has_immediate_user_input?(expr[3]) ? CONFIDENCE[:high] : CONFIDENCE[:med]
        message = "Render :update contains user input #{friendly_type_of input}"
        warn( #:result =>  # FIXME: result of tracker.find_call and such
          :code => expr,
          :warning_type => "Unescaped Render Update",
          :warning_code => :render_update,
          :message => message,
          :user_input => input.match,
          :confidence => confidence,
          :class => a_class,
          :method => a_method,
        )
        #binding.pry
      end
    #elsif expr[0] == :call
    #  check_expr(var, expr[1], a_class, a_method)
    end
  end

  def check_block(var, block, a_class, a_method)
    check_expr(var, block, a_class, a_method)
    block.each { |expr|
      binding.pry
      check_expr(var, expr, a_class, a_method)
    }
  end

  def run_check
    binding.pry
    tracker.find_call(:target => nil, :method => :render).each do |result|
      process_render_result result
    end

    #tracker.render_updates.each do |var, block, a_class, a_method|
    #  check_expr(var, block, a_class, a_method)
    #  block.each { |expr| check_expr(var, expr, a_class, a_method) }
    #end

# [1] pry(#<Brakeman::CheckRender>)> src
# => s(:methdef,
#  :filter1,
#  s(:args),
#  s(:iasgn,
#   :@user,
#   s(:call,
#    s(:const, :User),
#    :find,
#    s(:call, s(:params), :[], s(:lit, :user_id)))))
# [2] pry(#<Brakeman::CheckRender>)> set_name
# => :BeforeController
# [3] pry(#<Brakeman::CheckRender>)> method_name
# => :filter1
# [4] pry(#<Brakeman::CheckRender>)> definition
# => "/home/martin/Projects/brakeman/test/apps/rails3/app/controllers/before_controller.rb"
# 
    tracker.each_method do |src, set_name, method_name, definition|
      #if method_name == :else_test
        binding.pry
        find_call(src, :render, :update) do |expr|
          var  = (expr[2][1] rescue nil)
          expr = expr[3]
          #binding.pry
          check_block(var, expr, set_name, method_name)
        end
      #end
    end
  end

  def find_call(expr, method, arg1, &block)
    if expr[0] == :call_with_block &&
       expr[1] &&
       expr[1][0] == method &&
       expr[1][1] == arg1
      #binding.pry
      yield expr
    else
      expr.each do |sube|
        binding.pry
        next unless sube.respond_to?(:[])
        #binding.pry
        find_call(sube.then_clause, method, arg1, &block) if (sube.then_clause rescue false)
        find_call(sube.else_clause, method, arg1, &block) if (sube.else_clause rescue false)
        #binding.pry

        if sube[0] == :call_with_block &&
           sube[1] &&
           sube[1][0] == method &&
           sube[1][1] == arg1
          #binding.pry
          yield sube
        elsif sube[0] == :call_with_block
          #binding.pry
          find_call(sube.block, method, arg1, &block)
        end
      end
    end
  end

  def process_render_result result
    return unless node_type? result[:call], :render

    case result[:call].render_type
    when :partial, :template, :action, :file
      check_for_dynamic_path result
    when :inline
    when :js
    when :json
    when :text
    when :update
    when :xml
    end
  end

  #Check if path to action or file is determined dynamically
  def check_for_dynamic_path result
    view = result[:call][2]

    if sexp? view and not duplicate? result
      add_result result


      if input = has_immediate_user_input?(view)
        confidence = CONFIDENCE[:high]
      elsif input = include_user_input?(view)
        if node_type? view, :string_interp, :dstr
          confidence = CONFIDENCE[:med]
        else
          confidence = CONFIDENCE[:low]
        end
      else
        return
      end

      return if input.type == :model #skip models

      message = "Render path contains #{friendly_type_of input}"

      warn :result => result,
        :warning_type => "Dynamic Render Path",
        :warning_code => :dynamic_render_path,
        :message => message,
        :user_input => input.match,
        :confidence => confidence
    end
  end
end 
