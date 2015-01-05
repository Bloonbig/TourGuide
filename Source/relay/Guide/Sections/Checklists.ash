import "relay/Guide/Sections/Tests.ash"


void generateMisc(Checklist [int] checklists)
{
	if (__quest_state["Level 13"].state_boolean["king waiting to be freed"])
	{
		ChecklistEntry [int] unimportant_task_entries;
		string [int] king_messages;
		king_messages.listAppend("You know, whenever.");
		king_messages.listAppend("Or become the new naughty sorceress?");
		unimportant_task_entries.listAppend(ChecklistEntryMake("king imprismed", "lair6.php", ChecklistSubentryMake("Free the King", "", king_messages)));
		
		checklists.listAppend(ChecklistMake("Unimportant Tasks", unimportant_task_entries));
	}
	
	if (availableDrunkenness() < 0 && $item[drunkula's wineglass].equipped_amount() == 0)
	{
        //They're drunk, so tasks aren't as relevant. Re-arrange everything:
        string url;
        
        //Give them something to mindlessly click on:
        //url = "bet.php";
       if ($coinmaster[Game Shoppe].is_accessible())
            url = "aagame.php";
        
        
		Checklist task_entries = lookupChecklist(checklists, "Tasks");
		
		lookupChecklist(checklists, "Future Tasks").entries.listAppendList(lookupChecklist(checklists, "Tasks").entries);
		lookupChecklist(checklists, "Future Tasks").entries.listAppendList(lookupChecklist(checklists, "Optional Tasks").entries);
		lookupChecklist(checklists, "Future Unimportant Tasks").entries.listAppendList(lookupChecklist(checklists, "Unimportant Tasks").entries);
		
		lookupChecklist(checklists, "Tasks").entries.listClear();
		lookupChecklist(checklists, "Optional Tasks").entries.listClear();
		lookupChecklist(checklists, "Unimportant Tasks").entries.listClear();
		
        string [int] description;
        string line = "You're drunk.";
        if (__last_adventure_location == $location[Drunken Stupor])
            url = "campground.php";
        
        if (hippy_stone_broken() && pvp_attacks_left() > 0)
            url = "peevpee.php";
            
        description.listAppend(line);
        if ($item[drunkula's wineglass].available_amount() > 0 && $item[drunkula's wineglass].can_equip() && my_adventures() > 0)
        {
            description.listAppend("Or equip your wineglass.");
        }
        
        int rollover_adventures_from_equipment = 0;
        foreach s in $slots[]
            rollover_adventures_from_equipment += s.equipped_item().numeric_modifier("adventures").to_int();
        
        //detect if they're going to lose some turns, be nice:
        int rollover_adventures_gained = numeric_modifier("adventures").to_int() + 40;
        if (get_property_boolean("_borrowedTimeUsed"))
            rollover_adventures_gained -= 20;
        int adventures_lost = (my_adventures() + rollover_adventures_gained) - 200;
        if (rollover_adventures_from_equipment == 0.0 && adventures_lost == 0 && my_path_id() != PATH_SLOW_AND_STEADY)
        {
            description.listAppend("Possibly wear +adventures gear.");
        }
        if (adventures_lost > 0)
        {
            description.listAppend("You'll miss out on " + pluralizeWordy(adventures_lost, "adventure", "adventures") + ". Alas.|Could work out in the gym, craft, or play arcade games.");
        }
        
        //this could be better (i.e. checking against current shirt and looking in inventory, etc.)
        if (my_path_id() != PATH_SLOW_AND_STEADY)
        {
            if ($item[Sneaky Pete's leather jacket (collar popped)].equipped_amount() > 0 && adventures_lost <= 0)
                description.listAppend("Could unpop your collar. (+4 adventures)");
            if ($item[Sneaky Pete's leather jacket].equipped_amount() > 0 && hippy_stone_broken())
                description.listAppend("Could pop your collar. (+4 fights)");
            if (!can_interact() && $item[resolution: be more adventurous].available_amount() > 0 && get_property_int("_resolutionAdv") < 5)
            {
                description.listAppend("Use resolution: be more adventurous.");
            }
        }
        if (in_ronin() && pulls_remaining() > 0)
        {
            description.listAppend("Don't forget your " + pluralizeWordy(pulls_remaining(), "pull", "pulls") + ".");
        }
        //FIXME resolution be more adventurous goes here
        
		task_entries.entries.listAppend(ChecklistEntryMake("__item counterclockwise watch", url, ChecklistSubentryMake("Wait for rollover", "", description), -11));
        if (stills_available() > 0 && __misc_state["In Run"])
        {
            string url = "shop.php?whichshop=still";
            if ($item[soda water].available_amount() == 0)
                url = "store.php?whichstore=m";
            task_entries.entries.listAppend(ChecklistEntryMake("__item tonic water", url, ChecklistSubentryMake("Make " + pluralize(stills_available(), $item[tonic water]), "", listMake("Tonic water is a ~40MP restore, improved from soda water.", "Or improve drinks.")), -11));
        }
	}
}


void generateChecklists(Checklist [int] ordered_output_checklists)
{
	setUpState();
	setUpQuestState();
	
	if (__misc_state["Example mode"])
		setUpExampleState();
	
	finalizeSetUpState();
	
	Checklist [int] checklists;
	
    
    if (!playerIsLoggedIn())
    {
        //Hmm. I think emptying everything is the way to go, because if we're not online, we'll be inaccurate. Best to give no advice than some.
        //But, it might break in the future if our playerIsLoggedIn() detection is inaccurate?
        
		Checklist task_entries = lookupChecklist(checklists, "Tasks");
        
        string image_name;
        image_name = "disco bandit"; //tricky - they may not have this image in their image cache. Display nothing?
		task_entries.entries.listAppend(ChecklistEntryMake(image_name, "", ChecklistSubentryMake("Log in", "+internet", "An Adventurer is You!"), -11));
    }
    else if (__misc_state["In valhalla"])
    {
        //Valhalla:
		Checklist task_entries = lookupChecklist(checklists, "Tasks");
        task_entries.entries.listAppend(ChecklistEntryMake("astral spirit", "", ChecklistSubentryMake("Start a new life", "", listMake("Perm skills.", "Buy consumables.", "Bring along a pet."))));
    }
    else
    {
        generateDailyResources(checklists);
        
        generateTasks(checklists);
        if (__misc_state["Example mode"] || !__misc_state["In aftercore"])
        {
            generateMissingItems(checklists);
            generatePullList(checklists);
        }
        if (__setting_debug_show_all_internal_states && __setting_debug_mode)
        {
            generateImageTest(checklists);
            generateStateTest(checklists);
            generateCounterTest(checklists);
            generateSelfDataTest(checklists);
        }
        generateFloristFriar(checklists);
        
        
        generateMisc(checklists);
        generateStrategy(checklists);
    }
	
	//Remove checklists that have no entries:
	int [int] keys_to_remove;
	foreach key in checklists
	{
		Checklist cl = checklists[key];
		if (cl.entries.count() == 0)
			keys_to_remove.listAppend(key);
	}
	listRemoveKeys(checklists, keys_to_remove);
	listClear(keys_to_remove);
	
	//Go through desired output order:
	string [int] setting_desired_output_order = split_string_alternate("Tasks,Optional Tasks,Unimportant Tasks,Future Tasks,Resources,Future Unimportant Tasks,Required Items,Suggested Pulls,Florist Friar,Strategy", ",");
	foreach key in setting_desired_output_order
	{
		string title = setting_desired_output_order[key];
		//Find title in checklists:
		foreach key2 in checklists
		{
			Checklist cl = checklists[key2];
			if (cl.title == title)
			{
				ordered_output_checklists.listAppend(cl);
				keys_to_remove.listAppend(key2);
				break;
			}
		}
	}
	listRemoveKeys(checklists, keys_to_remove);
	listClear(keys_to_remove);
	
	//Add remainder:
	foreach key in checklists
	{
		Checklist cl = checklists[key];
		ordered_output_checklists.listAppend(cl);
	}
}



void outputChecklists(Checklist [int] ordered_output_checklists)
{
    if (__misc_state["In run"] && playerIsLoggedIn())
        PageWrite(HTMLGenerateDivOfClass("Day " + my_daycount() + ". " + pluralize(my_turncount(), "turn", "turns") + " played.", "r_bold"));
	if (my_path() != "" && my_path() != "None" && playerIsLoggedIn())
	{
		PageWrite(HTMLGenerateDivOfClass(my_path(), "r_bold"));
	}
    
    
    string chosen_message = generateRandomMessage();
    if (chosen_message.length() > 0)
        PageWrite(HTMLGenerateDiv(chosen_message));
    PageWrite(HTMLGenerateTagWrap("div", "", mapMake("id", "extra_words_at_top")));
	
	
	if (__misc_state["Example mode"])
	{
		PageWrite("<br>");
		PageWrite(HTMLGenerateDivOfStyle("Example ascension", "text-align:center; font-weight:bold;"));
	}
		
	if (my_path_id() == PATH_TRENDY) //trendy is unsupported
    {
        PageWrite("<br>");
		PageWrite(HTMLGenerateDiv("Trendy warning - advice may be dangerously out of style"));
    }

    Checklist extra_important_tasks;
    
	//And output:
	foreach i in ordered_output_checklists
	{
		Checklist cl = ordered_output_checklists[i];
        
        if (__show_importance_bar && cl.title == "Tasks")
        {
            foreach key in cl.entries
            {
                ChecklistEntry entry = cl.entries[key];
                if (entry.importance_level <= -11)
                {
                    extra_important_tasks.entries.listAppend(entry);
                }
                    
            }
        }
		PageWrite(ChecklistGenerate(cl));
	}
    
    if (__show_importance_bar && extra_important_tasks.entries.count() > 0)
    {
        extra_important_tasks.title = "Tasks";
        extra_important_tasks.disable_generating_id = true;
        PageWrite(HTMLGenerateTagPrefix("div", mapMake("id", "importance_bar", "style", "z-index:3;position:fixed; top:0;width:100%;max-width:" + __setting_horizontal_width + "px;border-bottom:1px solid;border-color:" + __setting_line_color + ";visibility:hidden;")));
		PageWrite(ChecklistGenerate(extra_important_tasks, false));
        PageWrite(HTMLGenerateTagSuffix("div"));
        
    }
}