/obj/structure/closet/secure_closet/scientist
	name = "scientist's locker"
	req_one_access = list(access_research)
	icon_state = "secure1"
	icon_closed = "secure"
	icon_locked = "secure1"
	icon_opened = "secureopen"
	icon_off = "secureoff"

/obj/structure/closet/secure_closet/scientist/WillContain()
	return list(
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/messenger/tox, /obj/item/storage/backpack/satchel_tox)),
		/obj/item/clothing/under/deadspace/research_assistant,
		/obj/item/clothing/suit/storage/toggle/labcoat,
		/obj/item/clothing/shoes/white,
		/obj/item/radio/headset/headset_sci,
		/obj/item/clothing/mask/gas,
		/obj/item/clipboard,
		/obj/random/tool
	)

/obj/structure/closet/secure_closet/xenobio
	name = "xenobiologist's locker"
	req_access = list(access_research)
	icon_state = "secureres1"
	icon_closed = "secureres"
	icon_locked = "secureres1"
	icon_opened = "secureresopen"
	icon_off = "secureresoff"

/obj/structure/closet/secure_closet/xenobio/WillContain()
	return list(
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/messenger/tox, /obj/item/storage/backpack/satchel_tox)),
		/obj/item/clothing/under/rank/scientist,
		/obj/item/clothing/suit/storage/toggle/labcoat,
		/obj/item/clothing/shoes/white,
		/obj/item/radio/headset/headset_sci,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/gloves/latex,
		/obj/item/clipboard,
		/obj/item/storage/belt/general,
		/obj/random/tool
	)

/obj/structure/closet/secure_closet/CSCIO
	name = "chief science officer's locker"
	req_access = list(access_cscio)
	icon_state = "secure1"
	icon_closed = "secure"
	icon_locked = "secure1"
	icon_opened = "secureopen"
	icon_off = "secureoff"

/obj/structure/closet/secure_closet/CSCIO/WillContain()
	return list(
		/obj/item/clothing/suit/bio_suit/scientist = 2,
		/obj/item/clothing/under/deadspace/chief_science_officer,
		/obj/item/clothing/suit/storage/toggle/labcoat,
		/obj/item/clothing/shoes/white,
		/obj/item/clothing/shoes/leather,
		/obj/item/clothing/gloves/latex,
		/obj/item/radio/headset/heads/cscio,
		/obj/item/clothing/mask/gas,
		/obj/item/flash,
		/obj/item/clipboard,
		/obj/item/clothing/suit/storage/toggle/labcoat/rd
	)
