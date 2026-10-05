// Halloween Trick-or-Treat Event Network PRO
// 05 - Leaderboard Controller | Creator: RockzHasan
integer TOP_COUNT = 10;
integer DISPLAY_INTERVAL = 15;
string gSession = "CLOSED";
// stride uuid, name, score, unique, complete
list gRows;
integer rowIndex(key avatar)
{
    integer i;
    for (i = 0; i < llGetListLength(gRows); i += 5) if (llList2Key(gRows, i) == avatar) return i;
    return -1;
}
list sortedRows()
{
    list work = gRows; list out;
    while (llGetListLength(work) >= 5 && llGetListLength(out) / 5 < TOP_COUNT)
    {
        integer best = 0; integer i;
        for (i = 5; i < llGetListLength(work); i += 5)
        {
            integer score = llList2Integer(work, i + 2); integer bestScore = llList2Integer(work, best + 2);
            integer visits = llList2Integer(work, i + 3); integer bestVisits = llList2Integer(work, best + 3);
            if (score > bestScore || (score == bestScore && visits > bestVisits)) best = i;
        }
        out += llList2List(work, best, best + 4);
        work = llDeleteSubList(work, best, best + 4);
    }
    return out;
}
integer redraw()
{
    list rows = sortedRows(); string text = "🎃 HALLOWEEN TOP " + (string)TOP_COUNT + " 🎃";
    integer i; integer rank = 1;
    for (i = 0; i < llGetListLength(rows); i += 5)
    {
        string name = llGetSubString(llList2String(rows, i + 1), 0, 19);
        text += "\n" + (string)rank + ". " + name + " — " + llList2String(rows, i + 2) + " candy";
        ++rank;
    }
    if (llStringLength(text) > 1000) text = llGetSubString(text, 0, 999);
    llSetText(text, <1.0,0.45,0.0>, 1.0);
    return 0;
}
default
{
    state_entry() { llSetTimerEvent((float)DISPLAY_INTERVAL); redraw(); }
    link_message(integer sender, integer number, string message, key id)
    {
        if (llJsonValueType(message, []) != JSON_ARRAY) return;
        list m = llJson2List(message); string command = llList2String(m, 0);
        if (command == "RESET_ALL") { gSession = llList2String(m, 1); gRows = []; redraw(); }
        else if (command == "RESET_PLAYER")
        { integer d = rowIndex(llList2Key(m, 2)); if (d != -1) gRows = llDeleteSubList(gRows, d, d + 4); }
        else if (command == "PLAYER_UPDATE" && llGetListLength(m) == 7 && llList2String(m, 1) == gSession)
        {
            list row = llList2List(m, 2, 6); integer p = rowIndex(llList2Key(m, 2));
            if (p == -1) gRows += row; else gRows = llListReplaceList(gRows, row, p, p + 4);
        }
    }
    timer() { redraw(); }
}
