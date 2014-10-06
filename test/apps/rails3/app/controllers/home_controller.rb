class HomeController < ApplicationController
  before_filter :filter_it, :only => :test_filter
  include JavaScriptHelper

#  def index # OK
#    bar = 1
#    render :update do |page|
#      page << params[:id]
#      page << bar
#      1+1
#      page << "foo"
#    end
#  end
#
#  def index0 # OK
#    render :update do |page|
#      page << params[:foo]
#    end
#  end
#
#  def index1 # OK
#    render :update do |page|
#      page << j(params[:foo])
#    end
#  end
#
#  def index2 # OK
#    render :update do |page|
#      page << escape_javascript(params[:foo])
#    end
#  end
#
#  def index3 # OK
#    render :update do |page|
#      page << "foo: #{params[:foo]}"
#    end
#  end
#
#  def index4 # OK
#    render :update do |page|
#      page << "foo:" + params[:foo]
#    end
#  end
#
#  def index5 # OK
#    render :update do |page|
#      foo = params[:foo]
#      page << "foo" + foo
#    end
#  end
#
#  def index6 # OK
#    if params[:id] == 1
#      render :update do |page|
#        page << params[:foo]
#      end
#    else
#      render :update do |page|
#        page << j(params[:foo])
#      end
#    end
#  end
#
#  def index7
#    10.times do |i|
#      render :update do |page|
#        page << params[:foo]
#      end
#    end
#
#    [1,2,3].each do |e|
#      render :update do |page|
#        page << "foo: #{params[:foo]}"
#      end
#    end
#  end
#
#  def ce_select
#    ce_get_form_vars
#    if params[:id] == "new"
#      render :update do |page|                    # Use JS to update the display
#        page.replace("flash_msg_div", :partial=>"layouts/flash_msg")
#        page.replace("classification_entries_div", :partial=>"classification_entries", :locals=>{:entry=>"new", :edit=>true})
#        page << "$('entry_name').focus();"
#        page << "$('entry_name').select();"
#      end
#      session[:entry] = "new"
#    else
#      entry = Classification.find(params[:id])
#      render :update do |page|                    # Use JS to update the display
#        page.replace("flash_msg_div", :partial=>"layouts/flash_msg")
#        page.replace("classification_entries_div", :partial=>"classification_entries", :locals=>{:entry=>entry, :edit=>true})
#        page << "$('entry_#{j_str(params[:field])}').focus();"
#        page << "$('entry_#{j_str(params[:field])}').select();"
#      end
#      session[:entry] = entry
#    end
#  end

  def else_test
    render :update do |page|
      page << 'foo'
      page << 'bar'
      page << "$('entry_#{params[:field1]}').select();"
    end
    #if params[:edit_entry] == "edit_file"
    #  render :update do |page|
    #    page << "$('entry_#{params[:field]}').focus();"
    #    page << "$('entry_#{params[:field]}').select();"
    #  end
    #elsif params[:edit_entry] == "edit_registry"
    #  render :update do |page|
    #    page << "$('entry_#{params[:field1]}').focus();"
    #    page << "$('entry_#{params[:field1]}').select();"
    #  end
    #else
    #  render :update do |page|
    #    page << 'foo'
    #    page << "$('entry_#{params[:field2]}').focus();"
    #    page << "$('entry_#{params[:field2]}').select();"
    #  end
    #end
  end

  def ap_ce_select
    return unless load_edit("ap_edit__#{params[:id]}","replace_cell__explorer")
    ap_get_form_vars
    if params[:edit_entry] == "edit_file"
      session[:edit_filename] = params[:file_name]
      render :update do |page|                    # Use JS to update the display
        page.replace("flash_msg_div", :partial=>"layouts/flash_msg")
        page.replace_html("ap_form_div", :partial=>"ap_form", :locals=>{:entry=>session[:edit_filename], :edit=>true})
        page << "$('entry_#{params[:field]}').focus();"
        page << "$('entry_#{params[:field]}').select();"
      end
    elsif params[:edit_entry] == "edit_registry"
      session[:reg_data] = Hash.new
      session[:reg_data][:key] = params[:reg_key]  if params[:reg_key]
      session[:reg_data][:value] = params[:reg_value] if params[:reg_value]
      render :update do |page|                    # Use JS to update the display
        page.replace("flash_msg_div", :partial=>"layouts/flash_msg")
        page.replace("ap_form_div", :partial=>"ap_form", :locals=>{:entry=>session[:reg_data], :edit=>true})
        page << "$('entry_#{params[:field]}').focus();"
        page << "$('entry_#{params[:field]}').select();"
      end
    elsif params[:edit_entry] == "edit_nteventlog"
      session[:nteventlog_data] = Hash.new
      session[:nteventlog_entries].sort_by { |r| r[:name] }.each_with_index do |nteventlog,i|
        if i == params[:entry_id].to_i
          session[:nteventlog_data][:selected] = i
          session[:nteventlog_data][:name] = nteventlog[:name]
          session[:nteventlog_data][:message] = nteventlog[:filter][:message]
          session[:nteventlog_data][:level] = nteventlog[:filter][:level]
          session[:nteventlog_data][:num_days] = nteventlog[:filter][:num_days].to_i
          #session[:nteventlog_data][:rec_count] = nteventlog[:filter][:rec_count].to_i
          session[:nteventlog_data][:source] = nteventlog[:filter][:source]
        end
      end

      render :update do |page|                    # Use JS to update the display
        page.replace("flash_msg_div", :partial=>"layouts/flash_msg")
        page.replace("ap_form_div", :partial=>"ap_form", :locals=>{:entry=>session[:nteventlog_data], :edit=>true})
        page << "$('entry_#{params[:field]}').focus();"
        page << "$('entry_#{params[:field]}').select();"
      end
    else
      session[:edit_filename] = ""
      session[:reg_data] = Hash.new
      session[:nteventlog_data] = Hash.new
      render :update do |page|                    # Use JS to update the display
        page.replace("flash_msg_div", :partial=>"layouts/flash_msg")
        page.replace("ap_form_div", :partial=>"ap_form", :locals=>{:entry=>"new", :edit=>true})
        page << "$('entry_name').focus();"
        page << "$('entry_name').select();"
      end
    end
  end

  def test_params
    @name = params[:name]
    @indirect = indirect_method(params[:input])
  end

  def test_model
    @name = User.first.name
  end

  def test_cookie
    @name = cookies[:name]
  end

  def test_filter
  end

  def test_file_access
    File.open RAILS_ROOT + "/" + params[:file]
  end

  def test_sql some_var = "hello"
    User.find_by_sql "select * from users where something = '#{some_var}'"
    User.all(:conditions => "status = '#{happy}'")
    @user = User.first(:conditions => "name = '#{params[:name]}'")
  end

  def test_command
    `ls #{params[:file_name]}`

    system params[:user_input]
  end

  def test_eval
    eval params[:dangerous_input]
  end

  def test_redirect
    params[:action] = :index
    redirect_to params
  end

  def test_render
    @some_variable = params[:unsafe_input]
    render :index
  end

  def test_mass_assignment
    User.new(params[:user])
  end

  def test_mass_assignment_with_hash
    User.new(:name => params[:user][:name])
  end

  def test_dynamic_render
    page = params[:page]
    render :file => "/some/path/#{page}"
  end

  def test_load_params
    load params[:file]
    RandomClass.load params[:file]
  end

  def test_model_build
    current_user = User.new
    current_user.something.something.build(params[:awesome_user])
  end

  def test_only_path_wrong
    redirect_to params[:user], :only_path => true #This should still warn
  end

  def test_url_for_only_path
    url = params
    url[:only_path] = false
    redirect_to url_for(url)
  end

  def test_render_a_method_call
    @user = User.find(params['user']).name
    render :test_render
  end

  def test_number_alias
    y + 1 + 2
  end

  def test_only_path_correct
    params.merge! :only_path => true
    redirect_to params
  end

  def test_content_tag
    @user = User.find(current_user)
  end

  def test_yaml_file_access
    #Should not warn about access, but about remote code execution
    YAML.load "some/path/#{params[:user][:file]}"

    #Should warn
    YAML.parse_file("whatever/" + params[:file_name])
  end

  def test_more_mass_assignment_methods
    #Additional mass assignment methods
    User.first_or_create(params[:user])
    User.first_or_create!(:name => params[:user][:name])
    User.first_or_initialize!(params[:user])
    User.update(params[:id], :alive => false) #No warning
    User.update(1, params[:update])
    User.find(1).assign_attributes(params[:update])
  end

  def test_yaml_load
    YAML.load params[:input]
    YAML.load some_method #No warning
    YAML.load x(cookies[:store])
    YAML.load User.first.bad_stuff
  end

  def test_more_yaml_methods
    YAML.load_documents params[:input]
    YAML.load_stream cookies[:thing]
    YAML.parse_documents "a: #{params[:a]}"
    YAML.parse_stream User.find(1).upload
  end

  def parse_json
    JSON.parse params[:input]
  end

  def mass_assign_slice_only
    Account.new(params.slice(:name, :email))
    Account.new(params.only(:name, email))
  end

  def test_more_ways_to_execute
    Open3.capture2 "ls #{params[:dir]}"
    Open3.capture2e "ls #{params[:dir]}"
    Open3.capture3 "ls #{params[:dir]}"
    Open3.pipeline "sort", "uniq", :in => params[:file]
    Open3.pipeline_r "sort #{params[:file]}", "uniq"
    Open3.pipeline_rw params[:cmd], "sort -g"
    Open3.pipeline_start *params[:cmds]
    spawn "some_cool_command #{params[:opts]}"
    POSIX::Spawn::spawn params[:cmd]
  end

  private

  def filter_it
    @filtered = params[:evil_input]
  end
end
