// Contains everything related to earning research points

/datum/experiment_data
	var/saved_best_explosion = 0

	var/list/tech_points = list(
		TECH_MATERIAL = 200,
		TECH_ENGINEERING = 250,
		TECH_PHORON = 500,
		TECH_POWER = 300,
		TECH_BLUESPACE = 1000,
		TECH_BIO = 300,
		TECH_COMBAT = 500,
		TECH_MAGNET = 350,
		TECH_DATA = 400,
		TECH_ILLEGAL = 2000,
		TECH_NECRO = 4000
	)

	// So we don't give points for researching non-artifact item
	var/list/artifact_types = list(
		/obj/machinery/auto_cloner,
		/obj/machinery/power/supermatter,
		/obj/structure/constructshell,
		/obj/machinery/giga_drill,
		/obj/structure/cult/pylon,
		/obj/mecha/working/hoverpod,
		/obj/machinery/replicator,
		/obj/structure/crystal,
		/obj/machinery/artifact
	)

	var/list/saved_tech_levels = list() // list("materials" = list(1, 4, ...), ...)
	var/list/saved_autopsy_weapons = list()
	var/list/saved_artifacts = list()
	var/list/saved_symptoms = list()
	var/list/saved_slimecores = list()

/datum/experiment_data/proc/get_object_research_value(obj/item/I, ignoreRepeat = FALSE)
	var/item_tech_points = 0
	var/has_new_tech = FALSE
	var/is_board = istype(I, /obj/item/circuitboard)

	for(var/T in I.origin_tech)
		if(tech_points[T])
			if(ignoreRepeat)
				item_tech_points += I.origin_tech[T] * tech_points[T]
			else
				if(saved_tech_levels[T] && (I.origin_tech[T] in saved_tech_levels[T])) // You only get a fraction of points if you researched items with this level already
					if(!is_board) // Boards are cheap to make so we don't give any points for repeats
						item_tech_points += I.origin_tech[T] * tech_points[T] * 0.1
				else
					item_tech_points += I.origin_tech[T] * tech_points[T]
					has_new_tech = TRUE

	if(!ignoreRepeat && !has_new_tech) // We are deconstucting the same items, cut the reward really hard
		item_tech_points = min(item_tech_points, 400)

	return round(item_tech_points)

/datum/experiment_data/proc/do_research_object(obj/item/I)
	for(var/T in I.origin_tech)
		if(!saved_tech_levels[T])
			saved_tech_levels[T] = list()

		if(!(I.origin_tech in saved_tech_levels[T]))
			saved_tech_levels[T] |= I.origin_tech[T]

// Returns ammount of research points received
/*/datum/experiment_data/proc/read_science_tool(obj/item/science_tool/I)
	var/points = 0

	for(var/weapon in I.scanned_autopsy_weapons)
		if(!(weapon in saved_autopsy_weapons))
			saved_autopsy_weapons += weapon

			// These give more points because they are rare or special
			var/list/special_weapons = list(
				"large organic needle" = 10000,
				"Hulk Foot" = 10000,
				"Explosive blast" = 5000,
				"Electronics meltdown" = 4000,
				"Low Pressure" = 3000,
				"Facepalm" = 2000,
				)
			if(special_weapons[weapon])
				points += special_weapons[weapon]
			else
				points += rand(5,10) * 200 // 1000-2000 points for random weapon

	for(var/list/artifact in I.scanned_artifacts)
		if(!(artifact["type"] in artifact_types)) // useless
			continue

		var/already_scanned = FALSE
		for(var/list/our_artifact in saved_artifacts)
			if(our_artifact["type"] == artifact["type"] && our_artifact["first_effect"] == artifact["first_effect"] && our_artifact["second_effect"] == artifact["second_effect"])
				already_scanned = TRUE
				break

		if(!already_scanned)
			points += rand(5,10) * 1000 // 5000-10000 points for random artifact
			saved_artifacts += list(artifact)

	for(var/symptom in I.scanned_symptoms)
		if(saved_symptoms[symptom])
			continue

		var/list/level_to_points = list(200,500,1000,2500,10000)
		var/level = I.scanned_symptoms[symptom]
		if(level_to_points[level])
			points += level_to_points[level]

		saved_symptoms[symptom] = level

	I.clear_data()
	return round(points)*/

/datum/experiment_data/proc/merge_with(datum/experiment_data/O)
	for(var/tech in O.saved_tech_levels)
		if(!saved_tech_levels[tech])
			saved_tech_levels[tech] = list()

		saved_tech_levels[tech] |= O.saved_tech_levels[tech]

	for(var/weapon in O.saved_autopsy_weapons)
		saved_autopsy_weapons |= weapon

	for(var/list/artifact in O.saved_artifacts)
		var/has_artifact = FALSE
		for(var/list/our_artifact in saved_artifacts)
			if(our_artifact["type"] == artifact["type"] && our_artifact["first_effect"] == artifact["first_effect"] && our_artifact["second_effect"] == artifact["second_effect"])
				has_artifact = TRUE
				break
		if(!has_artifact)
			saved_artifacts += list(artifact)

	for(var/symptom in O.saved_symptoms)
		saved_symptoms[symptom] = O.saved_symptoms[symptom]

	for(var/core in O.saved_slimecores)
		saved_slimecores |= core

	saved_best_explosion = max(saved_best_explosion, O.saved_best_explosion)


// Grants research points when explosion happens nearby
/obj/item/radio/beacon/explosion_watcher
	name = "Kinetic Energy Scanner"
	desc = "Scans the level of kinetic energy from explosions"

	channels = list("Science" = 1)

/*/obj/item/radio/beacon/explosion_watcher/ex_act(severity)
	return

/obj/item/radio/beacon/explosion_watcher/Initialize()
	. = ..()
	explosion_watcher_list += src

/obj/item/radio/beacon/explosion_watcher/Destroy()
	explosion_watcher_list -= src
	return ..()

/obj/item/radio/beacon/explosion_watcher/proc/react_explosion(turf/epicenter, power)
	power = round(power)
	var/calculated_research_points = -1
	for(var/obj/machinery/computer/rdconsole/RD in RDcomputer_list)
		if(RD.id == 1) // only core gets the science
			var/saved_power_level = RD.files.experiments.saved_best_explosion

			var/added_power = max(0, power - saved_power_level)
			var/already_earned_power = min(saved_power_level, power)

			calculated_research_points = added_power * 1000 + already_earned_power * 200

			if(power > saved_power_level)
				RD.files.experiments.saved_best_explosion = power

			RD.files.research_points += calculated_research_points

	if(calculated_research_points > 0)
		autosay("Detected explosion with power level [power], received [calculated_research_points] research points", name ,"Science", freq = radiochannels["Science"])
	else
		autosay("Detected explosion with power level [power], R&D console is missing or broken", name ,"Science", freq = radiochannels["Science"])
*/
// Universal tool to get research points from autopsy reports, virus info reports, archeology reports, slime cores
/obj/item/science_tool
	name = "science tool"
	icon_state = "science"
	item_state = "sciencetool"
	desc = "A hand-held device capable of extracting usefull data from various sources, such as paper reports and slime cores."
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 5
	throw_range = 10
	matter = list(MATERIAL_STEEL = 200)
	origin_tech = list(TECH_ENGINEERING = 1, TECH_BIO = 1)

	var/datum/experiment_data/experiments
	var/list/scanned_autopsy_weapons = list()
	var/list/scanned_artifacts = list()
	var/list/scanned_symptoms = list()
	var/list/scanned_slimecores = list()
	var/datablocks = 0

/obj/item/science_tool/Initialize()
	. = ..()
	experiments = new

/obj/item/science_tool/attack(mob/living/M, mob/living/user)
	return

/obj/item/science_tool/afterattack(obj/O, mob/living/user)
	var/scanneddata = 0

	if(istype(O, /obj/item/disk/research_points))
		var/obj/item/disk/research_points/disk = O
		to_chat(user, "<span class='notice'>[disk] stores approximately [disk.stored_points] research points</span>")
		return

/*	if(istype(O,/obj/item/paper/autopsy_report))
		var/obj/item/paper/autopsy_report/report = O
		for(var/datum/autopsy_data/W in report.autopsy_data)
			if(!(W.weapon in scanned_autopsy_weapons))
				scanneddata += 1
				scanned_autopsy_weapons += W.weapon

	if(istype(O, /obj/item/paper/artifact_info))
		var/obj/item/paper/artifact_info/report = O
		if(report.artifact_type)
			for(var/list/artifact in scanned_artifacts)
				if(artifact["type"] == report.artifact_type && artifact["first_effect"] == report.artifact_first_effect && artifact["second_effect"] == report.artifact_second_effect)
					to_chat(user, "<span class='notice'>[src] already has data about this artifact report</span>")
					return

			scanned_artifacts += list(list(
				"type" = report.artifact_type,
				"first_effect" = report.artifact_first_effect,
				"second_effect" = report.artifact_second_effect,
			))
			scanneddata += 1

	if(istype(O, /obj/item/paper/virus_report))
		var/obj/item/paper/virus_report/report = O
		for(var/symptom in report.symptoms)
			if(!scanned_symptoms[symptom])
				scanneddata += 1
				scanned_symptoms[symptom] = report.symptoms[symptom]*/

	if(scanneddata > 0)
		datablocks += scanneddata
		to_chat(user, "<span class='notice'>[src] received [scanneddata] data block[scanneddata>1?"s":""] from scanning [O]</span>")
	else if(istype(O, /obj/item))
		var/science_value = experiments.get_object_research_value(O)
		if(science_value > 0)
			to_chat(user, "<span class='notice'>Estimated research value of [O.name] is [science_value]</span>")
		else
			to_chat(user, "<span class='notice'>[O] has no research value</span>")

/obj/item/science_tool/proc/clear_data()
	scanned_autopsy_weapons = list()
	scanned_artifacts = list()
	scanned_symptoms = list()
	scanned_slimecores = list()
	datablocks = 0

/obj/item/disk/research_points
	name = "Important Disk"
	desc = "Looks a disk with some important information stored. Scientists might know what to do with it"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 30, MATERIAL_GLASS = 10)
	var/stored_points

/obj/item/disk/research_points/Initialize()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

	stored_points = rand(1,10)*1000

/obj/item/disk/research_points/rare/Initialize()
	. = ..()

	stored_points = rand(10, 20)*1000
