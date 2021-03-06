StairEnd = {
    north = {
        walled = {
            {  1, -1 },
            {  0, -1 },
            { -1, -1 },
            { -1,  0 },
            { -1,  1 },
            {  0,  1 },
            {  1,  1 },
        },
        corridor = {
            { 0, 0 },
            { 1, 0 },
            { 2, 0 },
        },
        stair = { 0, 0 },
        next = { 1, 0 },
    },
    south = {
        walled = {
            { -1, -1 },
            {  0, -1 },
            {  1, -1 },
            {  1,  0 },
            {  1,  1 },
            {  0,  1 },
            { -1,  1 },
        },
        corridor = {
            {  0, 0 },
            { -1, 0 },
            { -2, 0 },
        },
        stair = { 0, 0 },
        next = { -1, 0 },
    },
    west = {
        walled = {
            { -1,  1 },
            { -1,  0 },
            { -1, -1 },
            {  0, -1 },
            {  1, -1 },
            {  1,  0 },
            {  1,  1 },
        },
        corridor = {
            { 0, 0 },
            { 0, 1 },
            { 0, 2 },
        },
        stair = { 0, 0 },
        next = { 0, 1 },
    },
    east = {
        walled = {
            { -1, -1 },
            { -1,  0 },
            { -1,  1 },
            {  0,  1 },
            {  1,  1 },
            {  1,  0 },
            {  1, -1 },

        },
        corridor = {
            { 0,  0 },
            { 0, -1 },
            { 0, -2 },
        },
        stair = { 0, 0 },
        next = { 0, -1 },
    }
}
