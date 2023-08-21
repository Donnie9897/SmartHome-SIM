replace_existing_fact(OldFact, NewFact) :-
    call(OldFact), 
    !,
    retract(OldFact),
    assertz(NewFact).


remove_existing_fact(OldFact) :-
    call(OldFact), 
    retract(OldFact).




%outside(Id).
outside(Id) :- 
	\+ inside(Id).


%setInsideEffectors(Effectors, Value).
setInsideEffectors([H|T], Y) :-
    extractInsideEffectors([H|T], [], L),
    setEffectors(L, Y).

%setOutsideEffectors(Effectors, Value).
setOutsideEffectors([H|T], Y) :-
    extractOutsideEffectors([H|T], [], L),
    setEffectors(L, Y).

%setEffectors(Effectors, Value).
setEffectors([H|T], Y) :-
    T \== [],
    !,
    setEffectors(T, Y),
	replace_existing_fact(effectorValue(H,_), effectorValue(H, Y)),
    % write in a file the line of code to set the effector H to the value Y
    open('logActions.txt', append, Stream),
    write(Stream, 'setEffector('), write(Stream, H), write(Stream, ','), write(Stream, Y), write(Stream, ').'),nl(Stream),
    close(Stream).


setEffectors([H|_], Y) :-
    !,
	replace_existing_fact(effectorValue(H,_), effectorValue(H, Y)),
    % write in a file the line of code to set the effector H to the value Y
    open('logActions.txt', append, Stream),
    write(Stream, 'setEffector('), write(Stream, H), write(Stream, ','), write(Stream, Y), write(Stream, ').'),nl(Stream),
    close(Stream).

setEffectors(_, _).
    

%extractInsideEffectors(List, NewList, variable).
extractInsideEffectors([H|T], L,X) :-
    T \== [],
    inside(H),
    !,
    extractInsideEffectors(T, [H|L], X).

extractInsideEffectors([H|T], L, X) :-
    T\== [],
    \+ inside(H),
    !,
    extractInsideEffectors(T, L, X).

extractInsideEffectors([H|_], L,X) :-
    \+ inside(H),
    !,
    X = L.

extractInsideEffectors([H|_], L, X) :-
    inside(H),
    !,
    X = [H|L].

extractInsideEffectors(_, L, X) :-
    X = L.
 

%extractOutsideEffectors(List, NewList, variable).
extractOutsideEffectors([H|T], L,X) :-
    T \== [],
    outside(H),
    !,
    extractOutsideEffectors(T, [H|L], X).

extractOutsideEffectors([H|T], L, X) :-
    T\== [],
    \+ outside(H),
    !,
    extractOutsideEffectors(T, L, X).

extractOutsideEffectors([H|_], L,X) :-
    \+ outside(H),
    !,
    X = L.

extractOutsideEffectors([H|_], L, X) :-
    outside(H),
    !,
    X = [H|L].

extractOutsideEffectors(_, L, X) :-
    X = L.

%set(IdAction).
set(IdAction) :-  set(IdAction, _).

%set(IdAction, IdCondition).
set(IdAction, light) :- 
    sensor(SensorId_outside, light),
    outside(SensorId_outside),
    sensorValue(SensorId_outside, X),
    preference(IdAction, light, Y, Effectors),
    X >= Y,
	setOutsideEffectors(Effectors, Y),
	setInsideEffectors(Effectors, 0).
    
set(IdAction, light) :- 
    sensor(SensorId_outside, light),
    outside(SensorId_outside),
    sensorValue(SensorId_outside, X),
    preference(IdAction, light, Y, Effectors),
    X < Y,
	setOutsideEffectors(Effectors, 0), 
	setInsideEffectors(Effectors, Y).

setInsideEffectors_temp(X_temp_inside, Y_temp) :-
    (X_temp_inside < Y_temp ->  setEffectors([r], Y_temp), setEffectors([ac], 0); setEffectors([ac], Y_temp), setEffectors([r], 0) ).





set(IdAction, temp) :-
    preference(IdAction, temp, Y_temp, EffectorsTemp),
    sensor(SensorId_insideTemp, temp),
    sensorValue(SensorId_insideTemp, X_inside),
    inside(SensorId_insideTemp),
    X_inside =:= Y_temp,
    !.


set(IdAction, temp) :-
    preference(IdAction, temp, Y_temp, EffectorsTemp),
    sensor(SensorId_outsideTemp, temp),
    outside(SensorId_outsideTemp),
    sensorValue(SensorId_outsideTemp, X_outside),
    sensor(SensorId_insideTemp, temp),
    inside(SensorId_insideTemp),
    sensorValue(SensorId_insideTemp, X_inside),
    X_inside < Y_temp,
    X_outside > Y_temp,
	%check the value of the sensor wind 
    sensor(SensorId_wind, wind),
    outside(SensorId_wind),
    sensorValue(SensorId_wind, X_wind),
    preference(IdAction, wind, Y_wind, EffectorsWind),
    (X_wind =< Y_wind,
    sensor(SensorId_rain, rain),
    sensorValue(SensorId_rain, X_rain),
        (X_rain =:= 0 ->
        setOutsideEffectors(EffectorsTemp, 1),
        setInsideEffectors(EffectorsTemp, 0)
        ;
        setOutsideEffectors(EffectorsTemp, 0),
        setInsideEffectors_temp(X_inside, Y_temp)
        )
    ; 
    setOutsideEffectors(EffectorsTemp, 0),
	setInsideEffectors_temp(X_inside, Y_temp)
    ).







set(IdAction, temp) :-
    preference(IdAction, temp, Y_temp, EffectorsTemp),
    sensor(SensorId_outsideTemp, temp),
    outside(SensorId_outsideTemp),
    sensorValue(SensorId_outsideTemp, X_outside),
    sensor(SensorId_insideTemp, temp),
    inside(SensorId_insideTemp),
    sensorValue(SensorId_insideTemp, X_inside),
    X_inside < Y_temp,
    X_outside < Y_temp,
	setOutsideEffectors(EffectorsTemp, 0),
	setInsideEffectors_temp(X_inside, Y_temp).


set(IdAction, temp) :-
    preference(IdAction, temp, Y_temp, EffectorsTemp),
    sensor(SensorId_outsideTemp, temp),
    outside(SensorId_outsideTemp),
    sensorValue(SensorId_outsideTemp, X_outside),
    sensor(SensorId_insideTemp, temp),
    inside(SensorId_insideTemp),
    sensorValue(SensorId_insideTemp, X_inside),
    X_inside > Y_temp,
    X_outside > Y_temp,
	setOutsideEffectors(EffectorsTemp, 0),
	setInsideEffectors_temp(X_inside, Y_temp).



    
set(IdAction, temp) :-
    preference(IdAction, temp, Y_temp, EffectorsTemp),
    sensor(SensorId_outsideTemp, temp),
    outside(SensorId_outsideTemp),
    sensorValue(SensorId_outsideTemp, X_outside),
    sensor(SensorId_insideTemp, temp),
    inside(SensorId_insideTemp),
    sensorValue(SensorId_insideTemp, X_inside),
    X_inside > Y_temp,
    X_outside < Y_temp,
    %check the value of the sensor wind 
    sensor(SensorId_wind, wind),
    sensorValue(SensorId_wind, X_wind),
    preference(IdAction, wind, Y_wind, EffectorsWind),
    (X_wind > Y_wind -> 
    setOutsideEffectors(EffectorsTemp, 0), 
    setOutsideEffectors(EffectorsWind, 0), 
    setInsideEffectors_temp(X_inside, Y_temp)
    ; 
    sensor(SensorId_rain, rain),
    sensorValue(SensorId_rain, X_rain),
        (X_rain =:= 0 ->
        setOutsideEffectors(EffectorsTemp, 1),
        setOutsideEffectors(EffectorsWind, 1),
        setInsideEffectors(EffectorsTemp, 0)
        ;
        setOutsideEffectors(EffectorsTemp, 0),
        setOutsideEffectors(EffectorsWind, 0),
        setInsideEffectors_temp(X_inside, Y_temp)
        )
    ). 


set(IdAction, noise) :-
    preference(IdAction, noise, Y_noise, EffectorsNoise),
    sensor(SensorId_noise, noise),
    sensorValue(SensorId_noise, X_noise_outside),
    X_noise_outside > Y_noise,
    sensor(SensorId_insideTemp, temp),
    inside(SensorId_insideTemp),
    sensorValue(SensorId_insideTemp, X_temp_inside),
    preference(IdAction, temp, Y_temp, EffectorsTemp),
    X_temp_inside \== Y_temp,
    setOutsideEffectors(EffectorsNoise, 0),
    setInsideEffectors_temp(X_temp_inside, Y_temp).

set(IdAction, noise) :-
    preference(IdAction, noise, Y_noise, EffectorsNoise),
    sensor(SensorId_noise, noise),
    sensorValue(SensorId_noise, X_noise_outside),
    X_noise_outside > Y_noise,
    sensor(SensorId_insideTemp, temp),
    sensorValue(SensorId_insideTemp, X_temp_inside),
    preference(IdAction, temp, Y_temp, EffectorsTemp),
    X_temp_inside == Y_temp,
    setOutsideEffectors(EffectorsNoise, 0).



%memberCheck(Element, List).
memberCheck(H,[H|_]).
memberCheck(H,[_|T]) :- memberCheck(H,T).


%Reglas para SEGURIDAD //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
apply_security_conditions(Condition) :-
    securityCondition(Condition),
    sensorValue(Condition, Value),
    securityThreshold(Condition, Threshold),
    Value >= Threshold,
    setof(Effector, effector(Effector, Condition), Effectors),
    apply_effects(Effectors, 1). % Activar efectores de seguridad

apply_security_conditions(_).



%Reglas para aplicar los efectos de las condiciones de seguridad
apply_effects([], _).
apply_effects([Effector | Rest], Action) :-
    apply_effect(Effector, Action),
    apply_effects(Rest, Action).


%Regla para cuando una persona sale de la casa
persona_sale :-
    todas_las_personas_salieron, % Verificar si todas las personas han salido de la casa
    cerrar_puertas,              % Cerrar las puertas
    apagar_luces.                % Apagar las luces

%Regla  para verificar si todas las personas han salido de la casa
todas_las_personas_salieron :-
    findall(Persona, residente(Persona), Residentes),
    % Verificar si todas las personas están fuera del hogar
    todas_las_personas_afuera(Residentes).

%Regla  para verificar si todas las personas están afuera
todas_las_personas_afuera([]).
todas_las_personas_afuera([Persona | Resto]) :-
    persona_afuera(Persona),
    todas_las_personas_afuera(Resto).

%Regla  para determinar si una persona está afuera
persona_afuera(Persona) :-
    ubicacion_actual(Persona,fuera).

persona_afuera(juan) :-   % Ejemplo: Juan está afuera
    ubicacion_actual(juan, fuera).

persona_afuera(ana) :-    % Ejemplo: Ana está afuera
    ubicacion_actual(ana, fuera).

persona_afuera(maria) :-  % Ejemplo: Maria está afuera
    ubicacion_actual(maria, fuera).


%Regla para cerrar las puertas
cerrar_puertas :-
    findall(Effector, effector(Effector, door), DoorEffectors),
    setEffectors(DoorEffectors, 0). % Cierra las puertas (0 representa cerrado)

%Regla para apagar las luces
apagar_luces :-
    findall(Effector, effector(Effector, light), LightEffectors),
    setEffectors(LightEffectors, 0). % Apaga las luces (0 representa apagado)