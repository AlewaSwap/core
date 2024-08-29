program perpetual_dex.aleo;

mapping positions:
    key trader as address.public;
    value Position;

struct Position {
    collateral as u64.public;
    leverage as u64.public;
    entry_price as u64.public;
    size as u64.public;
    is_open as bool.public;
}

function open_position:
    // Inputs: trader's address, collateral amount, leverage, entry price, position size
    input r0 as address.private;
    input r1 as u64.private;
    input r2 as u64.private;
    input r3 as u64.private;
    input r4 as u64.private;

    // Calculate position size based on leverage
    mul r1 r2 into r5;

    // Create a new position
    let new_position = Position {
        collateral: r1,
        leverage: r2,
        entry_price: r3,
        size: r5,
        is_open: true
    };

    // Store the position in the mapping
    set r0 new_position into positions;

    // Output the new position
    output new_position as Position;

function close_position:
    // Inputs: trader's address, current market price
    input r0 as address.private;
    input r1 as u64.private;

    // Retrieve the position
    get r0 from positions into r2 as Position;

    // Ensure the position is still open
    assert r2.is_open == true;

    // Calculate PnL (Profit and Loss)
    mul r2.size r1 into r3;
    sub r3 r2.entry_price into r4;
    mul r4 r2.leverage into pnl;

    // Update position as closed
    let closed_position = Position {
        collateral: r2.collateral,
        leverage: r2.leverage,
        entry_price: r2.entry_price,
        size: r2.size,
        is_open: false
    };

    // Update the mapping
    set r0 closed_position into positions;

    // Output the closed position and PnL
    output closed_position as Position;
    output pnl as u64.private;

finalize close_position:
    // Input: trader's address
    input r0 as address.public;

    // Retrieve the closed position
    get r0 from positions into r1 as Position;

    // Ensure the position is closed
    assert r1.is_open == false;

    // Finalize the position by releasing collateral
    let finalized_collateral = r1.collateral;

    // Remove the position from the mapping
    remove r0 from positions;

    // Output the finalized collateral
    output finalized_collateral as u64.private;

function liquidate_position:
    // Inputs: trader's address, liquidation price
    input r0 as address.private;
    input r1 as u64.private;

    // Retrieve the position
    get r0 from positions into r2 as Position;

    // Ensure the position is still open
    assert r2.is_open == true;

    // Check if liquidation condition is met
    sub r2.entry_price r1 into r3;
    assert.lt r3 r2.collateral;

    // Mark the position as liquidated
    let liquidated_position = Position {
        collateral: 0u64,
        leverage: r2.leverage,
        entry_price: r2.entry_price,
        size: r2.size,
        is_open: false
    };

    // Update the mapping
    set r0 liquidated_position into positions;

    // Output the liquidated position
    output liquidated_position as Position;

finalize liquidate_position:
    // Input: trader's address
    input r0 as address.public;

    // Retrieve the liquidated position
    get r0 from positions into r1 as Position;

    // Ensure the position is liquidated
    assert r1.collateral == 0u64;

    // Finalize by removing the liquidated position from the mapping
    remove r0 from positions;

    // Output confirmation
    output true as bool.private;
