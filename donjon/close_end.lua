CloseEnd = {
    north = {
        walled = {
            { 0, -1 },
            { 1, -1 },
            { 1,  0 },
            { 1,  1 },
            { 0,  1 },
        },
        close = { 0, 0 },
        recurse = { -1, 0 },
    },
    south = {
        walled = {
            {  0, -1 },
            { -1, -1 },
            { -1,  0 },
            { -1,  1 },
            {  0,  1 },            
        },
        close = { 0, 0 },
        recurse = { 1, 0 },
    },
    west = {
        walled = {
            { -1, 0 },
            { -1, 1 },
            {  0, 1 },
            {  1, 1 },
            {  1, 0 },            
        },
        close = { 0, 0 },
        recurse = { 0, -1 },
    },
    east = {
        walled = {
            { -1,  0 },
            { -1, -1 },
            {  0, -1 },
            {  1, -1 },
            {  1,  0 },            
        },
        close = { 0, 0 },
        recurse = { 0, 1 },
    },
}
