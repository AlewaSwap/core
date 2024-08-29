// The 'perpetual_dex.aleo' program.
program perpetual_dex.aleo;

// Define a record for a perpetual position.
record position:
    owner as address.private;
    collateral as u64.private;
    leverage as u64.private;
    entry_price as u64.private;
    size as u64.private;
    is_open as bool.private;

// Define a function to open a position.
function open_position:
    // Input parameters.
    input r0 as address.private;    // Owner's address.
    input r1 as u64.private;        // Collateral amount.
    input r2 as u64.private;        // Leverage factor.
    input r3 as u64.private;        // Entry price.
    input r4 as u64.private;        // Position size.
    
    // Calculate the position size based on leverage.
    mul r1 r2 into r5;
    
    // Create a new position record.
    cast r0 r1 r2 r3 r4 true into r6 as position.record;

    // Output the new position.
    output r6 as position.record;

// Define a function to close a position.
function close_position:
    // Input the current position.
    input r0 as position.record;
    // Input the current market price.
    input r1 as u64.private;

    // Calculate PnL (Profit and Loss) based on the difference between the entry and current price.
    sub r1 r0.entry_price into r2;   // Price difference.
    mul r2 r0.size into r3;          // PnL in terms of size.
    
    // Update the position to mark it as closed.
    cast r0.owner r0.collateral r0.leverage r0.entry_price r0.size false into r4 as position.record;
    
    // Output the updated (closed) position and the PnL.
    output r4 as position.record;
    output r3 as u64.private;

// Define a function to transfer collateral between users.
function transfer_collateral:
    // Sender's address and collateral.
    input r0 as address.private;
    input r1 as u64.private;
    // Receiver's address.
    input r2 as address.private;
    // Amount to transfer.
    input r3 as u64.private;

    // Deduct the amount from the sender's collateral.
    sub r1 r3 into r4;

    // Add the amount to the receiver's collateral (assuming starting at 0).
    add 0u64 r3 into r5;

    // Create the updated records for sender and receiver.
    cast r0 r4 into r6 as position.record;
    cast r2 r5 into r7 as position.record;

    // Output the updated records.
    output r6 as position.record;
    output r7 as position.record;
