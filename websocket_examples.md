# WebSocket Connection Examples - UPDATED

## Now that ActionCable is properly configured, try these:

### 1. Using wscat (Recommended)
```bash
# Your token is still valid, so try connecting again:
wscat -c "ws://localhost:3000/cable?token=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2Iiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzUxOTAyOTUzLCJleHAiOjE3NTE5ODkzNTMsImp0aSI6ImFhMDQyMDZjLTIzYzEtNGNmMC04ZGM3LTg5NWQwZmMzYTM5MSJ9.lTXjmb1UETewjTP-8s9HgtAWpw1B4f1Znmtu_gjSLAw"

# After successful connection, send this to subscribe to the channel:
{"command":"subscribe","identifier":"{\"channel\":\"AssetPriceChannel\"}"}
```

### 2. Test the connection first
```bash
# Check if the cable endpoint is now available:
curl -I http://localhost:3000/cable
# Should return 101 Switching Protocols or 426 Upgrade Required (both are good)
```

### 3. Trigger a test message
```bash
# In another terminal, trigger price sync to see WebSocket messages:
curl -X POST http://localhost:3000/api/v1/asset_prices/sync \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2Iiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzUxOTAyOTUzLCJleHAiOjE3NTE5ODkzNTMsImp0aSI6ImFhMDQyMDZjLTIzYzEtNGNmMC04ZGM3LTg5NWQwZmMzYTM5MSJ9.lTXjmb1UETewjTP-8s9HgtAWpw1B4f1Znmtu_gjSLAw"
```

### What you should see:
1. **Connection successful**: "Connected (press CTRL+C to quit)"
2. **After subscribing**: Confirmation message
3. **When triggering sync**: Real-time asset price updates
