#!/usr/bin/env escript

main([BeamFile]) ->
  {ok,{_,[{abstract_code,{_,AC}}]}} = beam_lib:chunks(BeamFile,[abstract_code]),
  io:fwrite("~s~n", [erl_prettypr:format(erl_syntax:form_list(AC))]).
