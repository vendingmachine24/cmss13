//
//Robotic Component Analyser, basically a health analyser for robots
//
/obj/item/device/robotanalyzer
	name = "cyborg analyzer"
	icon_state = "robotanalyzer"
	item_state = "analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	throwforce = 3
	w_class = 2.0
	throw_speed = 5
	throw_range = 10
	matter = list("metal" = 200)
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1;

/obj/item/device/robotanalyzer/attack(mob/living/M as mob, mob/living/user as mob)
	if(( (CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
		user << text("<span class='danger'>You try to analyze the floor's vitals!</span>")
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span class='danger'>[user] has analyzed the floor's vitals!</span>"), 1)
		user.show_message(text(SPAN_NOTICE("Analyzing Results for The floor:\n\t Overall Status: Healthy")), 1)
		user.show_message(text(SPAN_NOTICE("\t Damage Specifics: [0]-[0]-[0]-[0]")), 1)
		user.show_message(SPAN_NOTICE("Key: Suffocation/Toxin/Burns/Brute"), 1)
		user.show_message(SPAN_NOTICE("Body Temperature: ???"), 1)
		return
	if(!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "<span class='danger'>You don't have the dexterity to do this!</span>")
		return
	if(!isrobot(M) && !(ishuman(M) && (M:species.flags & IS_SYNTHETIC)))
		to_chat(user, "<span class='danger'>You can't analyze non-robotic things!</span>")
		return

	user.visible_message("<span class='notice'> [user] has analyzed [M]'s components.","<span class='notice'> You have analyzed [M]'s components.")
	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
	user.show_message(SPAN_NOTICE("Analyzing Results for [M]:\n\t Overall Status: [M.stat > 1 ? "fully disabled" : "[M.health - M.halloss]% functional"]"))
	user.show_message("\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>", 1)
	user.show_message("\t Damage Specifics: <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>")
	if(M.tod && M.stat == DEAD)
		user.show_message(SPAN_NOTICE("Time of Disable: [M.tod]"))

	if (isrobot(M))
		var/mob/living/silicon/robot/H = M
		var/list/damaged = H.get_damaged_components(1,1,1)
		user.show_message(SPAN_NOTICE("Localized Damage:"),1)
		if(length(damaged)>0)
			for(var/datum/robot_component/org in damaged)
				user.show_message(text("<span class='notice'>\t []: [][] - [] - [] - []</span>",	\
				capitalize(org.name),					\
				(org.installed == -1)	?	"<font color='red'><b>DESTROYED</b></font> "							:"",\
				(org.electronics_damage > 0)	?	"<font color='#FFA500'>[org.electronics_damage]</font>"	:0,	\
				(org.brute_damage > 0)	?	"<font color='red'>[org.brute_damage]</font>"							:0,		\
				(org.toggled)	?	"Toggled ON"	:	"<font color='red'>Toggled OFF</font>",\
				(org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>"),1)
		else
			user.show_message(SPAN_NOTICE("\t Components are OK."),1)
		if(H.emagged && prob(5))
			user.show_message("<span class='danger'>\t ERROR: INTERNAL SYSTEMS COMPROMISED</span>",1)

	if (ishuman(M) && (M:species.flags & IS_SYNTHETIC))
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_limbs(1,1)
		user.show_message(SPAN_NOTICE("Localized Damage, Brute/Electronics:"),1)
		if(length(damaged)>0)
			for(var/datum/limb/org in damaged)
				var/msg_display_name = "[capitalize(org.display_name)]" // Here for now until we purge this useless shitcode
				var/msg_brute_dmg = "[(org.brute_dam > 0)	?	"<span class='danger'>[org.brute_dam]</span>" : "0"]"
				var/msg_burn_dmg = "[(org.brute_dam > 0)	?	"<span class='danger'>[org.brute_dam]</span>" : "0"]"
				user.show_message(SPAN_NOTICE("\t [msg_display_name]: [msg_brute_dmg] - [msg_burn_dmg]"), 1)
		else
			user.show_message(SPAN_NOTICE("\t Components are OK."),1)

	user.show_message(SPAN_NOTICE("Operating Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)"), 1)

	src.add_fingerprint(user)
	return
