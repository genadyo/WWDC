#!/usr/bin/env ruby
require "JSON"

def wrapping(scope)
  f  = scope[:function_name]
  f_ = f.tr(":","_")
  r_k  = scope[:return_object][:kind]
  r  = scope[:return_object][:type]
  c  = scope[:class]
  args = scope[:args] || []
  arg_list  = args.inject("") { |memo, o|
    "#{memo}, #{o[:name]}" 
  } 
  arg_names  = args.each_with_index.inject("") { |memo, (o, index)| 
    if o[:kind] == "Record"
      value = "recordPointer"
      dereferncingPrefix = "*(#{o[:type]}*)"
    else
      value = o[:kind][0, 1].downcase + o[:kind][1..-1] + "Value"
      dereferncingPrefix = ""
    end
    "#{memo}, #{dereferncingPrefix}((RolloutTypeWrapper*)arguments[#{index}]).#{value}" 
  } 
  arg_dec  = args.inject("")  { |memo, o|  
    "#{memo}, #{o[:type]} #{o[:name]}"
  }
  ns_f = "@\"#{f}\""
  ns_c = "@\"#{c}\""

  t = scope[:type]
  imp = " _rollout_impl_#{c}_#{f_}_#{t}"
  decl_args_list = "(id rcv, SEL _cmd#{arg_dec})"
  store = "_rollout_storage_#{c}_#{f_}_#{t}"
  call_store = "#{store}(rcv, _cmd#{arg_names})"
  set_original_return_value = "#{call_store};"
  set_original_return_value_if_nil_invocation = "#{store}(rcv, _cmd#{arg_list});"
  set_original_return_value_if_nil_invocation_with_return = "#{set_original_return_value_if_nil_invocation} return;"
  decrale_r = "" 
  return_var = ""
  return_expression = ""
  tryCatchDefaultValue = ""
  replaceReturnValue = ""
  disableValue = ""

  arguments = ""
  args.each { |arg|
    if "Record" == arg[:kind]
      arguments << "     [[RolloutTypeWrapper alloc] initWithRecordPointer:&#{arg[:name]} ofSize:sizeof(#{arg[:type]}) shouldBeFreedInDealloc:NO], \n"
    else
      arguments << "     [[RolloutTypeWrapper alloc] initWith#{arg[:kind]}:#{arg[:name]}], \n"
    end
  }

  if args.length > 0
    tweaked_arguments = "NSArray *arguments = inv.tweakedArguments;"
  end

  if r != "void"
    return_var = "__rollout_r"
    set_original_return_value = "inv.originalReturnValue = [[RolloutTypeWrapper alloc] initWith#{r_k}:#{call_store}];"
    set_original_return_value_if_nil_invocation_with_return = "return #{set_original_return_value_if_nil_invocation}"
    decrale_r= "RolloutTypeWrapper *#{return_var};"
    return_expression = "return #{return_var}.#{r_k[0, 1].downcase}#{r_k[1..-1]}Value;";
    tryCatchDefaultValue = "#{return_var} = [inv tryCatchReturnValue];"
    replaceReturnValue = "#{return_var} =   [inv conditionalReturnValue];"
    disableValue = "#{return_var} =         [inv disableReturnValue];"
  end 
  if r_k == "Record"
    set_original_return_value = "{#{r} record = #{call_store};\n              inv.originalReturnValue = [[RolloutTypeWrapper alloc] initWithRecordPointer:&record ofSize:sizeof(#{r}) shouldBeFreedInDealloc:NO];}"
    return_expression = "return *((#{r} *)#{return_var}.recordPointer);";
  end
  return "
#ifdef ROLLOUT_SWIZZLE_DEFINITION_AREA
static #{r} #{imp}#{decl_args_list};
static #{r} (*#{store})#{decl_args_list};
#{r} #{imp}#{decl_args_list}{
    #{decrale_r}
    NSArray *originalArguments = @[#{arguments}];
    RolloutInvocationsList *invocationsList = [RolloutInvocationsListFactory invocationsListFor#{t}Method:#{ns_f} forClass:#{ns_c}];
    RolloutInvocation *inv = [invocationsList invocationForArguments:originalArguments];

    if(!inv) {
       #{set_original_return_value_if_nil_invocation_with_return}
    }

    [inv runBefore];

    inv.originalArguments = originalArguments;
    #{tweaked_arguments}

    switch ([inv type]) {
        case RolloutInvocationTypeDisable:
            #{disableValue}
            break;
        case RolloutInvocationTypeTryCatch:
            @try{
              #{set_original_return_value}
              #{replaceReturnValue}
            }
            @catch(id e){
                [inv runAfterExceptionCaught];
                #{tryCatchDefaultValue}
            }
            break;
        case RolloutInvocationTypeNormal:
        default:
              #{set_original_return_value};
              #{replaceReturnValue}
            break;
    }
    #{return_expression}
}
#endif
#ifdef ROLLOUT_SWIZZLE_ACT_AREA
if ([RolloutInvocationsListFactory shouldSetup#{t}Swizzle:#{ns_f} forClass:#{ns_c}]){
  rollout_swizzle#{t}MethodAndStore(NSClassFromString(#{ns_c}), @selector(#{f}),(IMP)#{imp}, (IMP*)&#{store});
  [RolloutInvocationsListFactory mark#{t}Swizzle:#{ns_f} forClass:#{ns_c}];
}
#endif
"
end

symbols  = JSON.parse(IO.read(ARGV[0]))

ignored_types = ["ConstantArray", "IncompleteArray", "FunctionProto", "Invalid", "Unexposed", "NullPtr","Overload","Dependent","ObjCId","ObjCClass","ObjCSel","FirstBuiltin","LastBuiltin","Complex","LValueReference","RValueReference","Typedef","ObjCInterface","FunctionNoProto","Vector","VariableArray","DependentSizedArray","MemberPointer"]

def fix_type_issue(data)
 # Special - CXType_BlockPointer  CXType_Record   CXType_Enum  CXType_Pointer  CXType_ObjCObjectPointer  
  keep_types = [ "UShort","Char16","Char_U","Char16","Char32","Int128","UInt128","Bool","Float","Short","Long","WChar","ULong","Double","Int","Void","Char_S","UChar","SChar","LongLong","ULongLong","UInt","LongDouble"]
  case 
  when "ObjCObjectPointer" == data["kind"]
    return { :type => "id", :kind => data["kind"]}
  when "Pointer" == data["kind"]
    return  { :type => "void*", :kind => data["kind"]}
  when "BlockPointer" == data["kind"]
    return { :type => "id", :kind => data["kind"]}
  when "Enum" == data["kind"]
    return { :type => "__rollout_enum", :kind => data["kind"]}
  when "Record" == data["kind"]
    #return { :type => "ROLLOUT_TYPE_WITH_SIZE(#{data["size"].to_i})", :kind => data["kind"]}
    return { :type =>  data["type"], :kind => data["kind"]}
  when keep_types.include?( data["kind"])
    return { :type => data["type"], :kind => data["kind"]}
  else
    return "ROLLOUT_ERROR(#{data["kind"]}, #{data["type"]}, #{data["size"]})"
  end
end


extract_arguments_with_types = lambda { |a|
  t  =  fix_type_issue(a)
  t[:name] = "__rollout_var_#{a["symbol"]}"
  t
}


valid_for_swizzeling  = lambda { |m|
  puts "//#{m["symbol"]} removed" if m["__should_be_removed"]
  return false if m["__should_be_removed"]
  return false if m["symbol"] == "dealloc" 
  true
}
def figure_out_import(d)
  file = d["file"]
  if d["is_in_system_header"] != 0 
    match = file.match(/\/([^\/]*)\.framework\/Headers\/([^\/]*.h)$/)
    if match
      framework, header = match.captures
      return "<#{framework}/#{header}>"
    end
  else
    match = file.match(/([^\/]*.h)$/)
    if match
      header = match.captures[0]
      return "\"#{header}\""
    end
  end
  return nil
end

puts "#ifdef ROLLOUT_SWIZZLE_DEFINITION_AREA"
defines = []
#types = [] ;
symbols.each { |f| 
  f.each {|c|
    c["children"].select(&valid_for_swizzeling).each { |m| 
      m["args"].each { |a| 
        #types.push(a["size"]) if a["kind"] == "Record" 
        m["__should_be_removed"] = true if ignored_types.include?( a["kind"])
        if a["kind"] == "Record"
          import = figure_out_import(a)
          if import
            defines.push(import)
          else 
            m["__should_be_removed"] = true
          end
        end
      }
      #types.push(m["return"]["size"]) if m["return"]["kind"] == "Record" 
      m["__should_be_removed"] = true  if ignored_types.include?( m["return"]["kind"]) 
      if m["return"]["kind"] == "Record"
        import = figure_out_import(m["return"])
        if import
          defines.push(import)
        else 
          m["__should_be_removed"] = true
        end
      end
    }
  }
}
defines.uniq().each { |i|
  puts "#import #{i}"
}
#types.uniq().each { |s| 
#  puts "CREATE_ROLLOUT_TYPE_WITH_SIZE(#{s.to_i})"
#}
puts "#endif"

symbols.each { |f| 
  f.each {|c|
    c["children"].select(&valid_for_swizzeling).each { |m| 
      method_return_object = fix_type_issue(m["return"])
      arguments_with_types  = m["args"].map(&extract_arguments_with_types)
      puts wrapping({
        :class => c["symbol"],
        :return_object => method_return_object,
        :type =>  m["kind"] == "instance" ? "Instance" : "Class",
        :function_name => m["symbol"],
        :args => arguments_with_types
      })
    }
  }
}
