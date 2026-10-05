// Halloween Trick-or-Treat Event Network PRO
// 04 - Reward / Prize Controller | Creator: RockzHasan
string RARE_PRIZE = "Rare Halloween Prize";
string COMPLETION_PRIZE = "Halloween Completion Prize";
integer ANNOUNCE_COMPLETION = TRUE;
// delivery ledger prevents duplicate link events; entries are kind|avatar and clear each session
list gDelivered;
integer inventoryCanDeliver(string item)
{
    return item != "" && llGetInventoryType(item) != INVENTORY_NONE;
}
integer deliver(key avatar, string kind)
{
    string sessionKey = kind + "|" + (string)avatar;
    if (llListFindList(gDelivered, [sessionKey]) != -1) return 0;
    string item = RARE_PRIZE;
    if (kind == "COMPLETE") item = COMPLETION_PRIZE;
    if (!inventoryCanDeliver(item))
    { llOwnerSay("REWARD ERROR: inventory item missing: " + item); return 0; }
    llGiveInventory(avatar, item);
    gDelivered += [sessionKey];
    if (kind == "COMPLETE" && ANNOUNCE_COMPLETION)
        llRegionSay(0, "A resident completed the Halloween Trick-or-Treat challenge!");
    return 0;
}
default
{
    changed(integer c) { if (c & CHANGED_OWNER) llResetScript(); }
    link_message(integer sender, integer number, string message, key id)
    {
        if (llJsonValueType(message, []) != JSON_ARRAY) return;
        list m = llJson2List(message);
        string command = llList2String(m, 0);
        if (command == "RESET_ALL") gDelivered = [];
        else if (command == "RESET_PLAYER" && llGetListLength(m) == 3)
        {
            string suffix = "|" + (string)llList2Key(m, 2);
            integer i; list keep;
            for (i = 0; i < llGetListLength(gDelivered); ++i)
                if (llGetSubString(llList2String(gDelivered, i), -37, -1) != suffix)
                    keep += [llList2String(gDelivered, i)];
            gDelivered = keep;
        }
        else if (command == "AWARD" && llGetListLength(m) == 4)
            deliver(llList2Key(m, 2), llList2String(m, 3));
    }
}
