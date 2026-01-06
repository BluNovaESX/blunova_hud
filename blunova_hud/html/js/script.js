// ═══════════════════════════════════════════════════
//  MODERN HUD - JAVASCRIPT
// ═══════════════════════════════════════════════════

const HUD = {
    // Status Elements
    healthRing: document.getElementById('health-ring'),
    armorRing: document.getElementById('armor-ring'),
    armorStat: document.getElementById('armor-stat'),
    hungerRing: document.getElementById('hunger-ring'),
    thirstRing: document.getElementById('thirst-ring'),
    
    // Mic
    micIndicator: document.getElementById('mic-indicator'),
    
    // Money
    cashValue: document.getElementById('cash-value'),
    bankValue: document.getElementById('bank-value'),
    cashBox: document.getElementById('cash-box'),
    bankBox: document.getElementById('bank-box'),
    
    // Vehicle
    vehicleHud: document.getElementById('vehicle-hud'),
    speedValue: document.getElementById('speed-value'),
    speedRing: document.getElementById('speed-ring'),
    fuelFill: document.getElementById('fuel-fill'),
    fuelValue: document.getElementById('fuel-value'),
    engineIcon: document.getElementById('engine-icon'),
    beltIcon: document.getElementById('belt-icon'),
    
    // Player
    playerId: document.getElementById('player-id')
};

HUD.config = { maxSpeed: 250, useMPH: false };

// ═══════════════════════════════════════════════════
//  HELPER FUNCTIONS
// ═══════════════════════════════════════════════════

function formatMoney(amount) {
    return '$' + amount.toLocaleString('de-DE');
}

function updateCircle(element, value, max = 100) {
    const percentage = Math.max(0, Math.min(100, (value / max) * 100));
    element.setAttribute('stroke-dasharray', `${percentage}, 100`);
    
    // Warning bei niedrigen Werten
    const parent = element.closest('.circle-stat');
    if (percentage <= 20) {
        parent.classList.add('warning');
    } else {
        parent.classList.remove('warning');
    }
}

function updateSpeedometer(speed, maxSpeed) {
    if (!maxSpeed) maxSpeed = HUD.config.maxSpeed || 250;
    const maxDash = 213; // 75% des Kreises (270°)
    const percentage = Math.min(speed / maxSpeed, 1);
    const dashValue = percentage * maxDash;
    HUD.speedRing.style.strokeDasharray = `${dashValue}, 283`;
}

// ═══════════════════════════════════════════════════
//  NUI MESSAGE HANDLER
// ═══════════════════════════════════════════════════

window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch(data.action) {
        case 'setConfig':
            if (typeof data.maxSpeed === 'number') HUD.config.maxSpeed = data.maxSpeed;
            if (typeof data.useMPH === 'boolean') HUD.config.useMPH = data.useMPH;
            break;
        case 'updateStatus':
            handleStatus(data);
            break;
            
        case 'updateMoney':
            handleMoney(data);
            break;
            
        case 'updateVehicle':
            handleVehicle(data);
            break;
            
        case 'showVehicleHud':
            toggleVehicleHud(data.show);
            break;
            
        case 'updateMic':
            handleMic(data.talking);
            break;
            
        case 'updatePlayerId':
            HUD.playerId.textContent = 'ID: ' + data.id;
            break;
            
        case 'updateSeatbelt':
            handleSeatbelt(data.buckled);
            break;
            
        case 'hideHud':
            handleHideHud(data.hide);
            break;
    }
});

// ═══════════════════════════════════════════════════
//  HANDLER FUNCTIONS
// ═══════════════════════════════════════════════════

function handleStatus(data) {
    if (data.health !== undefined) {
        updateCircle(HUD.healthRing, data.health, 100);
    }
    
    if (data.armor !== undefined) {
        updateCircle(HUD.armorRing, data.armor, 100);
        // Armor ausblenden wenn 0
        if (data.armor <= 0) {
            HUD.armorStat.classList.add('empty');
        } else {
            HUD.armorStat.classList.remove('empty');
        }
    }
    
    if (data.hunger !== undefined) {
        updateCircle(HUD.hungerRing, data.hunger, 100);
    }
    
    if (data.thirst !== undefined) {
        updateCircle(HUD.thirstRing, data.thirst, 100);
    }
}

function handleMoney(data) {
    if (data.cash !== undefined) {
        const oldCash = HUD.cashValue.textContent;
        HUD.cashValue.textContent = formatMoney(data.cash);
        
        if (oldCash !== formatMoney(data.cash)) {
            HUD.cashBox.classList.add('updated');
            setTimeout(() => HUD.cashBox.classList.remove('updated'), 500);
        }
    }
    
    if (data.bank !== undefined) {
        const oldBank = HUD.bankValue.textContent;
        HUD.bankValue.textContent = formatMoney(data.bank);
        
        if (oldBank !== formatMoney(data.bank)) {
            HUD.bankBox.classList.add('updated');
            setTimeout(() => HUD.bankBox.classList.remove('updated'), 500);
        }
    }
}

function handleVehicle(data) {
    if (data.speed !== undefined) {
        HUD.speedValue.textContent = Math.round(data.speed);
        updateSpeedometer(data.speed, HUD.config.maxSpeed || 250);
    }
    
    if (data.fuel !== undefined) {
        const fuelPercent = Math.round(data.fuel);
        HUD.fuelFill.style.width = fuelPercent + '%';
        HUD.fuelValue.textContent = fuelPercent + '%';
        
        // Low fuel warning
        if (fuelPercent <= 20) {
            HUD.fuelFill.classList.add('low');
        } else {
            HUD.fuelFill.classList.remove('low');
        }
    }
    
    if (data.engine !== undefined) {
        if (data.engine) {
            HUD.engineIcon.classList.add('active');
        } else {
            HUD.engineIcon.classList.remove('active');
        }
    }
}

function toggleVehicleHud(show) {
    if (show) {
        HUD.vehicleHud.classList.add('active');
    } else {
        HUD.vehicleHud.classList.remove('active');
    }
}

function handleMic(talking) {
    if (talking) {
        HUD.micIndicator.classList.add('talking');
    } else {
        HUD.micIndicator.classList.remove('talking');
    }
}

function handleSeatbelt(buckled) {
    if (buckled) {
        HUD.beltIcon.classList.add('active');
    } else {
        HUD.beltIcon.classList.remove('active');
    }
}

function handleHideHud(hide) {
    const elements = [
        document.getElementById('status-hud'),
        document.getElementById('money-hud'),
        document.getElementById('vehicle-hud'),
        document.getElementById('player-id-box')
    ];
    
    elements.forEach(el => {
        if (el) {
            if (hide) {
                el.classList.add('hidden');
            } else {
                el.classList.remove('hidden');
            }
        }
    });
}

// ═══════════════════════════════════════════════════
//  INITIALIZATION
// ═══════════════════════════════════════════════════

document.addEventListener('DOMContentLoaded', () => {
    // Set initial values
    handleStatus({
        health: 100,
        armor: 0,
        hunger: 100,
        thirst: 100
    });
    
    handleMoney({
        cash: 0,
        bank: 0
    });
    
    console.log('[Modern HUD] Initialized');
});
