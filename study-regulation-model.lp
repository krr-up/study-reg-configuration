#const max_sem=4.

type(plan).
type(semester).
type(module).

% Partonomy
    part(plan, semester, (sem, 1..max_sem)).
    multiplicity(plan, semester, (sem, 1..max_sem), 1).

    part(semester, module, module).
    multiplicity(semester, module, module,1..8).

% Attributes
    attr(plan, totalcp, "sum").

    attr(semester, season, "discrete").
    dom(semester, season, (w;s)).

    attr(semester,id,"discrete").
    dom(semester,id,1..max_sem).

    attr(semester, totalcp, "sum").

    attr(module, id, "discrete").
    dom(module, id, ID) :- in(ID, _).

    attr(module, cp, "discrete").
    dom(module, cp, (6;9;12;15;30)).

    attr(module, sem, "discrete").
    dom(module, sem, (w;s)).


% IDs in the right order
    constraint((plan,(id,1..max_sem)),"table").
    column((plan,(id,Y)),0,(id,((sem,Y),()))) :- Y = 1..max_sem.
    entry((plan,(id,Y)),(0,0),Y) :- Y = 1..max_sem.


% Defines order and gives connection ports
    %connected(((sem,Y),((),0)),((sem,Y-1),((),0)),previous) :- selected(((sem,Y),((),0))), Y>1.


% Alternating Seasons
% With ID
    % Always starts with winter
    constraint((semester,seasons), "table").
    column((semester,seasons),0,(id,())). column((semester,seasons),1,(season,())).
    entry((semester,seasons),(0,Y),Y) :- Y=1..max_sem. 
    entry((semester,seasons),(1,Y),w) :- Y = 1..max_sem, Y\2=0.
    entry((semester,seasons),(1,Y),s) :- Y = 1..max_sem, Y\2=1.


% Module season restrictions
    constraint((semester, moduleSeasons), "eq").
    left((semester, moduleSeasons),(season,())).
    right((semester, moduleSeasons),(sem, (module,()))).



% Use the right values depending on the module ID
    constraint((module,data), "table").
    column((module,data),0,(id,())). column((module,data),1,(cp,())). column((module,data),2,(sem,())).
    entry((module,data),(0,ID), ID) :- in(ID, _).
    entry((module,data),(1,ID), CP) :- map(c,ID,CP), in(ID, _).
    entry((module,data),(2,ID), w) :- map(s,ID,(w;e)), in(ID, _).
    entry((module,data),(2,ID), s) :- map(s,ID,(s;e)), in(ID, _).



% Aggregate Path for CP
    path(plan, totalcp,(cp,(module,((sem,1..max_sem),())))). 

% Total CP constraint
    constraint((plan,totalcpl), "eq").
    left((plan,totalcpl),(totalcp,())).
    right((plan,totalcpl),constant(N)) :- map(l,m,N).
    %constraint((plan,totalcpu), "leq").
    %left((plan,totalcpu),(totalcp,())).
    %right((plan,totalcpu),constant(N)) :- map(u,m,N).


% Making sure modules are not chosen multiple times
:- val(((module,A),id),ID), val(((module,B),id),ID), A!=B.

% Mandatory modules
:- not val(((module,_),id),msc).





% TODO:
% Thesis CP requirement (temporal constraint)
% Groups

type(group).
part(plan, group, group).
multiplicity(plan, group, group, N) :- #count{1,G : in(_, G)} = N.

attr(group,id,"discrete").
dom(group,id,ID) :- in(_, ID).
:- val(((group,A),id),ID), val(((group,B),id),ID), A!=B.

connected((group,GROUPPATH),(module,MODULEPATH),grouped) :- val(((group,GROUPPATH),id),GID), val(((module,MODULEPATH),id),MID), in(MID,GID).


attr(group, totalcp, "sum").
path(group, totalcp, (cp,(module,(grouped,())))).

