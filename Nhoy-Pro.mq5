//+------------------------------------------------------------------+
//|                                                  Nhoy-Pro.mq5    |
//|                                    Copyright 2026, Daj Account   |
//|                                             Version 2.2          |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Daj Account Soon"
#property link      "https://www.mql5.com"
#property version   "1.20"
#property strict

#include <Trade\Trade.mqh>

// ==================================================================
// 🛠️ MQL4 COMPATIBILITY WRAPPERS FOR MQL5
// ==================================================================
double iClose(string symbol, int timeframe, int shift) {
   ENUM_TIMEFRAMES tf = (timeframe == 0) ? _Period : (ENUM_TIMEFRAMES)timeframe;
   double close[];
   ArraySetAsSeries(close, true);
   if(CopyClose(symbol, tf, shift, 1, close) > 0) return close[0];
   return 0.0;
}

double iOpen(string symbol, int timeframe, int shift) {
   ENUM_TIMEFRAMES tf = (timeframe == 0) ? _Period : (ENUM_TIMEFRAMES)timeframe;
   double open[];
   ArraySetAsSeries(open, true);
   if(CopyOpen(symbol, tf, shift, 1, open) > 0) return open[0];
   return 0.0;
}

double iHigh(string symbol, int timeframe, int shift) {
   ENUM_TIMEFRAMES tf = (timeframe == 0) ? _Period : (ENUM_TIMEFRAMES)timeframe;
   double high[];
   ArraySetAsSeries(high, true);
   if(CopyHigh(symbol, tf, shift, 1, high) > 0) return high[0];
   return 0.0;
}

double iLow(string symbol, int timeframe, int shift) {
   ENUM_TIMEFRAMES tf = (timeframe == 0) ? _Period : (ENUM_TIMEFRAMES)timeframe;
   double low[];
   ArraySetAsSeries(low, true);
   if(CopyLow(symbol, tf, shift, 1, low) > 0) return low[0];
   return 0.0;
}

datetime iTime(string symbol, int timeframe, int shift) {
   ENUM_TIMEFRAMES tf = (timeframe == 0) ? _Period : (ENUM_TIMEFRAMES)timeframe;
   datetime time[];
   ArraySetAsSeries(time, true);
   if(CopyTime(symbol, tf, shift, 1, time) > 0) return time[0];
   return 0.0;
}

// --- ENUM FOR TRAILING & TARGET TYPE ---
enum ENUM_TARGET_MODE {
   TARGET_MODE_USD = 0,  
   TARGET_MODE_PIPS = 1,
};

enum ENUM_TRAIL_MODE {
   TRAIL_MODE_PERCENT = 0, 
   TRAIL_MODE_PIPS = 1     
};

enum ENUM_LOT_MODE {
   MODE_DEFAULT = 0,         
   MODE_FIBO = 1, 
   MODE_HYBRID_FIBO = 2
};

// ==================================================================
// 🔒 ផ្នែកប្រព័ន្ធអាជ្ញាប័ណ្ណសម្ងាត់ (LICENSE PROTECTION SYSTEM)
// ==================================================================
input group "=== ONLINE LICENSE SYSTEM ===";
input string LicenseKey         = "SMC-KH-30DAYS-DEMO";
input string LicenseServerUrl   = "http://127.0.0.1:8888/verify";

string g_licenseExpiry = "Pending Check";

input group "===== MULTI-BOT =====";
input int          InpMagic          = 1111;            

input group "===== LOT SIZE =====";
input double      BaseLot              = 0.01;
input ENUM_LOT_MODE LotMultiplier_Mode = MODE_HYBRID_FIBO;
input double      LotMultiplier        = 1.5;         
input double      MaxLotSizeCap        = 5.0;       

input group "===== STOCHASTIC & BOLLINGER BANDS =====";
input bool        EnableStochFilter    = false;
input int         Stoch_K              = 14;            
input int         Stoch_D              = 3;             
input int         Stoch_Slowing        = 3;             
input int         StochOverSold        = 20; 
input int         StochOverBought      = 80;
input int         BB_Period            = 20;            
input double      BBDeviation          = 2.0;
input int         BBWidthLookback      = 50;   
input double      BBWidthMasterMultiplier = 1.5;

input group "===== SNIPER =====";
input bool      EnableSniper         = true;    
input double    SniperLot            = 0.01;     
input int       SniperTP_Pips        = 70;          
input int       MaxSniperTrades      = 1;
input int       SniperSL_Pips        = 100;
input double    MinBodyPips          = 40.0;  

input group "===== TREND FOLLOW =====";
input bool      EnableTrendZone        = false;    
input double    AtrMultiplier          = 0.7;    
input double    TrendLotSize           = 0.01;  
input bool      UseHybridFilter        = false; 
input ENUM_TIMEFRAMES ScanTimeframe    = 0; 
input bool        EnableDivergence     = true;          
input int         RSIPeriod            = 9;            
input int         RSIDivLookback       = 35;  

input group "===== SMART HEDGE =====";
input bool      EnableSmartHedge     = false;   
input double    MinATR_Pips          = 250.0;    
input double    MaxATR_Pips          = 300.0;   
input double    MiddleDistPips       = 5.0; 

input group "===== ICT & HTF FILTER =====";
input bool      EnableICTBias        = false;  
input int       StructureLookback    = 20;
input bool      EnableHTFFilter      = true;          
input ENUM_TIMEFRAMES HTF_Timeframe  = 0;
input int       HTF_EMA_Period       = 20;            
input ENUM_MA_METHOD HTF_MA_Method   = MODE_EMA;

input group "===== GRID & DYNAMIC STEP =====";
input bool      EnableDynamicStep    = true;
input double    StepLvl1             = 200.0;
input double    StepLvl2             = 300.0; 
input double    StepLvl3             = 200.0; 
input int       MaxSpreadPips        = 360; 
input int       MaxOpenTrades        = 8888;            
input double    LayerCapSize         = 0.8;      

input group "===== TAKE PROFIT & EQUITY ====="; 
input bool      EnableTrailing           = true;    
input ENUM_TARGET_MODE TrailingType      = TARGET_MODE_USD; 
input double    TrailingStopUSD          = 0.7;    
input double    TrailingStopPips         = 50.0; 
input double    TrailingPullbackPercent  = 20.0;
input bool      EnableEquityProtection   = false; 
input double    MaxDrawdownPercent       = 80.0;     
input bool      EnableProfitDaily        = false;    
input double    ProfitDaily              = 1000.0;

input group "===== SIDE BASKET PROFIT =====";
input bool      EnableSideTP             = true;    
input int       MinLayersForSideTP       = 2;     
input double    InpBaseExtraPips         = 5.0;    
input bool      EnableDynamicSideTP      = true;    
input int       InpIncrementalPips       = 10;    
input bool      EnableSideTrailing       = true;   
input int       SideTrailingPips         = 20;

input group "===== NEWS FILTER =====";
input bool      EnableNewsFilter         = true;          
input int       StopBeforeNews           = 30;            
input int       StopAfterNews            = 30;

input group "===== SESSION FILTER =====";
input bool      EnableSessionFilter      = true;      
input int       StartHour                = 5;         
input int       StartMinute              = 0;
input int       EndHour                  = 3;      
input int       EndMinute                = 0;
input bool      UseSoftClose             = true;

// --- Global Variables ---
CTrade           trade;
int              atrH, atrH_Long, bbH, stochH, htfH, rsiH;
double           currentAdaptiveStep = 200.0;
datetime         lastBarTime = 0, lastHedgeBar = 0, lastSniperBar = 0;
datetime         lastTrendBarB = 0, lastTrendBarS = 0; 
bool             g_isLicenseValid = false;
double           initialBalance = 0;
bool             g_limitReached = false;
double           highestSideValueB = -99999, highestSideValueS = -99999;
string           g_currentAction = "SCANNING", g_divSignal = "NONE", g_newsStatus = "SAFE", g_marketSignal = "SIDEWAY";
string           g_marketVolStatus = "SAFE";
int              g_marketBias = 0, g_ictBias = 0, g_motionStep = 0, g_iconY_Offset = 0, g_animColorStep = 0;
datetime         g_nextNewsTime = 0; 
string           g_newsEvent = "NONE";
string           g_newsCountdown = "00:00:00"; 
double           g_trendBuyStrength = 0, g_trendSellStrength = 0;
double           maxDD_Session = 0;

struct TTrack { ulong ticket; double highVal; };
TTrack g_ticketTracker[];

// --- Forward Declarations for Code Organization ---
void CreatePremiumDashboard();
void UpdateDashboardValues();
void UpdateDashboardMotion();
void CreateLabel(string n, int x, int y, string t, int sz, color col);
void CreateRect(string n, int x, int y, int w, int h, color bg);
void CreateHLine(string n, int x, int y, int w, color col);
void FetchNewsFromWeb();
bool IsNewsTime();
bool VerifyLicenseOnline();
string ParseJSONString(string json, string key);
double GetPositionCommission(ulong ticket);
double GetSideAveragePrice(ENUM_POSITION_TYPE type);
void MonitorPerTradeTrailing();
void MonitorSideDynamicLogic(int m);
void ExecuteUltimateStrategy();
void OpenOrder(ENUM_POSITION_TYPE t, double l);
double CalculateSafeLot(int c);
double GetDynamicStep(int l);
void ManageSniperTP();
int GetOpenSniperCount();
bool CheckAndExecuteSmartHedge();
void CloseSide(int m, ENUM_POSITION_TYPE t);
void UpdateFullAdaptiveLogic();
void CheckRiskProtections();
void CloseAllNow(string r);
bool IsInLocalSession();
int GetICTMarketBias();
int GetHTFTrendBias();
int GetRSIDivergence();
bool CheckInitialGridEntry(int div);
void CalculateTrendAndSignal();
bool ManageTrendZoneEntry();
bool ExecuteCandleSniper();
bool IsBBWidthSafe();

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit() {
   if(!VerifyLicenseOnline())
   {
      Alert("❌ LICENSE ERROR: Invalid, Expired, or Unauthorized Account for this License Key!");
      ExpertRemove();
      return(INIT_FAILED);
   }
   g_isLicenseValid = true;

   atrH      = iATR(_Symbol, _Period, 14);
   atrH_Long = iATR(_Symbol, _Period, 50);
   bbH       = iBands(_Symbol, _Period, BB_Period, 0, BBDeviation, PRICE_CLOSE);
   stochH    = iStochastic(_Symbol, _Period, Stoch_K, Stoch_D, Stoch_Slowing, MODE_SMA, STO_LOWHIGH);
   htfH      = iMA(_Symbol, HTF_Timeframe, HTF_EMA_Period, 0, HTF_MA_Method, PRICE_CLOSE);
   rsiH      = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE);
   
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetTypeFillingBySymbol(_Symbol);
   initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   ObjectsDeleteAll(0, "DB_");
   CreatePremiumDashboard();
   EventSetMillisecondTimer(150);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) { ObjectsDeleteAll(0, "DB_"); EventKillTimer(); }

//+------------------------------------------------------------------+
//| OnTimer                                                          |
//+------------------------------------------------------------------+
void OnTimer() { 
   g_motionStep++; if(g_motionStep >= 8) g_motionStep = 0; 
   int jump[] = {0, -2, -4, -5, -4, -2, 0, 0}; g_iconY_Offset = jump[g_motionStep];
   g_animColorStep++; if(g_animColorStep >= 20) g_animColorStep = 0;
   CalculateTrendAndSignal();
   UpdateDashboardMotion();   
   UpdateDashboardValues();
}

//+------------------------------------------------------------------+
//| OnTick                                                           |
//+------------------------------------------------------------------+
void OnTick() {
   if(!g_isLicenseValid) return;
   CheckRiskProtections(); 
   if(g_limitReached) { g_currentAction = "PAUSED"; UpdateDashboardValues(); return; }
   if(IsNewsTime()) { g_currentAction = "PAUSE(NEWS)"; UpdateDashboardValues(); return; }
   
   IsBBWidthSafe();
   
   int bC=0, sC=0;
   for(int i=0; i<PositionsTotal(); i++) {
      if(PositionSelectByTicket(PositionGetTicket(i)) && PositionGetInteger(POSITION_MAGIC)==InpMagic && PositionGetString(POSITION_SYMBOL)==_Symbol) {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) bC++; else sC++;
      }
   }
   int totalPos = bC + sC;
   bool inSession = IsInLocalSession();
   
   ManageSniperTP(); 
   MonitorPerTradeTrailing(); 
   MonitorSideDynamicLogic(InpMagic); 
   UpdateFullAdaptiveLogic(); 
   
   if(EnableSessionFilter && !inSession) {
      if(UseSoftClose && totalPos > 0) {
         g_currentAction = "CLEARING";
         datetime currentBar = iTime(_Symbol, _Period, 0);
         if(currentBar != lastBarTime) { ExecuteUltimateStrategy(); lastBarTime = currentBar; }
         UpdateDashboardValues(); return; 
      } else {
         if(totalPos > 0 && !UseSoftClose) CloseAllNow("Session End");
         g_currentAction = "OFF SESSION"; UpdateDashboardValues(); return; 
      }
   }

   g_marketBias = GetHTFTrendBias(); g_ictBias = GetICTMarketBias();
   int divSignal = GetRSIDivergence(); 
   
   if(inSession) {
      bool coreTriggered = false;
      if(totalPos == 0) {
         if(EnableSmartHedge && CheckAndExecuteSmartHedge()) { coreTriggered = true; g_currentAction = "Smart Hedge"; }
         if(!coreTriggered && EnableTrendZone && ManageTrendZoneEntry()) { coreTriggered = true; g_currentAction = "Trend Follow"; } 
         if(!coreTriggered && CheckInitialGridEntry(divSignal)) { coreTriggered = true; g_currentAction = "BDI"; }
         if(!coreTriggered && EnableSniper && ExecuteCandleSniper()) { coreTriggered = true; g_currentAction = "Sniper"; }
         if(!coreTriggered) g_currentAction = "SCANNING";
      }
   }
   if(totalPos > 0) {
      datetime currentBar = iTime(_Symbol, _Period, 0);
      if(currentBar != lastBarTime) { ExecuteUltimateStrategy(); lastBarTime = currentBar; }
   }
   UpdateDashboardValues();
}

// --- Helper Functions ---
double GetPositionCommission(ulong ticket) {
    double comm = 0;
    if(HistorySelectByPosition(ticket)) {
        for(int i=0; i<HistoryDealsTotal(); i++) {
            ulong deal_ticket = HistoryDealGetTicket(i);
            if(HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID) == ticket) {
                comm += HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION);
            }
        }
    }
    return comm;
}

double GetSideAveragePrice(ENUM_POSITION_TYPE type) {
    double totalLot = 0, weightedPrice = 0;
    for(int i=0; i<PositionsTotal(); i++) {
        if(PositionSelectByTicket(PositionGetTicket(i)) && PositionGetInteger(POSITION_MAGIC)==InpMagic && PositionGetInteger(POSITION_TYPE)==type) {
            double lot = PositionGetDouble(POSITION_VOLUME);
            totalLot += lot;
            weightedPrice += PositionGetDouble(POSITION_PRICE_OPEN) * lot;
        }
    }
    return (totalLot > 0) ? (weightedPrice / totalLot) : 0;
}

//+------------------------------------------------------------------+
//| MONITOR TRAILING PER TRADE                                       |
//+------------------------------------------------------------------+
void MonitorPerTradeTrailing() {
   if(!EnableTrailing) return;
   int buyCount = 0, sellCount = 0;
   for(int i=0; i<PositionsTotal(); i++) {
      if(PositionSelectByTicket(PositionGetTicket(i)) && PositionGetInteger(POSITION_MAGIC) == InpMagic && PositionGetString(POSITION_SYMBOL) == _Symbol) {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) buyCount++; else sellCount++;
      }
   }
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == InpMagic && PositionGetString(POSITION_SYMBOL) == _Symbol) {
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(type == POSITION_TYPE_BUY && buyCount > 1) continue; 
         if(type == POSITION_TYPE_SELL && sellCount > 1) continue;
         double netP = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP) + GetPositionCommission(ticket);
         double op = PositionGetDouble(POSITION_PRICE_OPEN);
         double pips = (type == POSITION_TYPE_BUY) ? (SymbolInfoDouble(_Symbol, SYMBOL_BID) - op) / (_Point * 10) : (op - SymbolInfoDouble(_Symbol, SYMBOL_ASK)) / (_Point * 10);
         double currentVal = (TrailingType == TARGET_MODE_USD) ? netP : pips;
         double triggerVal = (TrailingType == TARGET_MODE_USD) ? TrailingStopUSD : TrailingStopPips;
         int idx = -1;
         for(int k=0; k<ArraySize(g_ticketTracker); k++) { if(g_ticketTracker[k].ticket == ticket) { idx = k; break; } }
         if(idx == -1) {
            int nS = ArraySize(g_ticketTracker) + 1; ArrayResize(g_ticketTracker, nS);
            g_ticketTracker[nS-1].ticket = ticket; g_ticketTracker[nS-1].highVal = -99999; idx = nS-1;
         }
         if(currentVal >= triggerVal) {
            if(currentVal > g_ticketTracker[idx].highVal) g_ticketTracker[idx].highVal = currentVal;
            double pb = g_ticketTracker[idx].highVal * (TrailingPullbackPercent / 100.0);
            if(g_ticketTracker[idx].highVal - currentVal >= pb) trade.PositionClose(ticket);
         } else g_ticketTracker[idx].highVal = -99999;
      }
   }
   for(int k=ArraySize(g_ticketTracker)-1; k>=0; k--) if(!PositionSelectByTicket(g_ticketTracker[k].ticket)) {
      for(int j=k; j<ArraySize(g_ticketTracker)-1; j++) g_ticketTracker[j] = g_ticketTracker[j+1];
      ArrayResize(g_ticketTracker, ArraySize(g_ticketTracker)-1);
   }
}

//+------------------------------------------------------------------+
//| MONITOR SIDE DYNAMIC LOGIC                                       |
//+------------------------------------------------------------------+
void MonitorSideDynamicLogic(int m) {
   if(!EnableSideTP) return;
   
   int bCount=0, sCount=0;
   for(int i=0; i<PositionsTotal(); i++) {
      if(PositionSelectByTicket(PositionGetTicket(i)) && PositionGetInteger(POSITION_MAGIC) == m && PositionGetString(POSITION_SYMBOL) == _Symbol) {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) bCount++; else sCount++;
      }
   }

   // --- BUY SIDE LOGIC ---
   if(bCount >= MinLayersForSideTP) {
      double avgPrice = GetSideAveragePrice(POSITION_TYPE_BUY);
      double currentPips = (SymbolInfoDouble(_Symbol, SYMBOL_BID) - avgPrice) / (_Point * 10);
      double targetPips = InpBaseExtraPips;
      if(EnableDynamicSideTP) targetPips += (bCount - 2) * InpIncrementalPips;

      if(currentPips >= targetPips) {
         if(EnableSideTrailing) {
            if(currentPips > highestSideValueB) highestSideValueB = currentPips;
            if(highestSideValueB - currentPips >= SideTrailingPips) { CloseSide(m, POSITION_TYPE_BUY); highestSideValueB = -99999; }
         } else { CloseSide(m, POSITION_TYPE_BUY); }
      } else highestSideValueB = -99999;
   }

   // --- SELL SIDE LOGIC ---
   if(sCount >= MinLayersForSideTP) {
      double avgPrice = GetSideAveragePrice(POSITION_TYPE_SELL);
      double currentPips = (avgPrice - SymbolInfoDouble(_Symbol, SYMBOL_ASK)) / (_Point * 10);
      double targetPips = InpBaseExtraPips;
      if(EnableDynamicSideTP) targetPips += (sCount - 2) * InpIncrementalPips;

      if(currentPips >= targetPips) {
         if(EnableSideTrailing) {
            if(currentPips > highestSideValueS) highestSideValueS = currentPips;
            if(highestSideValueS - currentPips >= SideTrailingPips) { CloseSide(m, POSITION_TYPE_SELL); highestSideValueS = -99999; }
         } else { CloseSide(m, POSITION_TYPE_SELL); }
      } else highestSideValueS = -99999;
   }
}

//+------------------------------------------------------------------+
//| EXECUTE ULTIMATE STRATEGY (GRID)                                 |
//+------------------------------------------------------------------+
void ExecuteUltimateStrategy() {
   int bC=0, sC=0; double lastB=0, lastS=0;
   for(int i=0; i<PositionsTotal(); i++) {
      if(PositionSelectByTicket(PositionGetTicket(i)) && PositionGetInteger(POSITION_MAGIC)==InpMagic && PositionGetString(POSITION_SYMBOL)==_Symbol) {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) { bC++; if(lastB==0 || PositionGetDouble(POSITION_PRICE_OPEN)<lastB) lastB=PositionGetDouble(POSITION_PRICE_OPEN); }
         else { sC++; if(lastS==0 || PositionGetDouble(POSITION_PRICE_OPEN)>lastS) lastS=PositionGetDouble(POSITION_PRICE_OPEN); }
      }
   }
   if(g_limitReached || (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > MaxSpreadPips || bC+sC >= MaxOpenTrades) return;
   double bStp = EnableDynamicStep ? GetDynamicStep(bC) : currentAdaptiveStep, sStp = EnableDynamicStep ? GetDynamicStep(sC) : currentAdaptiveStep;
   if(bC > 0 && SymbolInfoDouble(_Symbol,SYMBOL_BID) <= (lastB - (bStp * _Point * 10))) OpenOrder(POSITION_TYPE_BUY, CalculateSafeLot(bC));
   if(sC > 0 && SymbolInfoDouble(_Symbol,SYMBOL_ASK) >= (lastS + (sStp * _Point * 10))) OpenOrder(POSITION_TYPE_SELL, CalculateSafeLot(sC));
}

void OpenOrder(ENUM_POSITION_TYPE t, double l) { trade.SetExpertMagicNumber(InpMagic); if(t==POSITION_TYPE_BUY) trade.Buy(l,_Symbol); else trade.Sell(l,_Symbol); }

double CalculateSafeLot(int c) {
   double lot = BaseLot;
   double hybridFiboScale[] = {0.01, 0.01, 0.02, 0.03, 0.05, 0.07, 0.11, 0.17, 0.25, 0.29, 0.38, 0.57, 0.86};

   if(LotMultiplier_Mode == MODE_HYBRID_FIBO) {
      if(c < 10) { // Layer 1 ដល់ 10 (index 0 ដល់ 9) ប្រើច្បាប់ Hybrid Fibo
         lot = hybridFiboScale[c];
      } 
      else { // Layer 11 ឡើងទៅ (index 10 ឡើងទៅ) ប្រើច្បាប់គុណ Default Martingale
         double lastFiboLot = hybridFiboScale[9]; // ឡូតរបស់ Layer 10 គឺ 0.29
         int extraLayers = c - 9; // ចំនួន Layer ដែលលើសពី ១០
         lot = lastFiboLot * MathPow(LotMultiplier, extraLayers);
      }
   }
   else if(LotMultiplier_Mode == MODE_FIBO) {
      int maxLayers = ArraySize(hybridFiboScale);
      if(c < maxLayers) lot = hybridFiboScale[c];
      else lot = LayerCapSize; 
   }
   else {
      if(c >= 14) lot = LayerCapSize;
      else lot = BaseLot * MathPow(LotMultiplier, c);
   }
   return NormalizeDouble(MathMin(lot, MaxLotSizeCap), 2);
}

double GetDynamicStep(int l) { if(l < 4) return StepLvl1; if(l < 10) return StepLvl2; return StepLvl3; }

void ManageSniperTP() {
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == InpMagic && PositionGetString(POSITION_COMMENT) == "Sniper") {
         double op = PositionGetDouble(POSITION_PRICE_OPEN);
         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { 
            // Take Profit
            if(SymbolInfoDouble(_Symbol,SYMBOL_BID) >= op + (SniperTP_Pips * _Point * 10)) {
               trade.PositionClose(ticket);
               continue;
            }
            // Stop Loss
            if(SniperSL_Pips > 0 && SymbolInfoDouble(_Symbol,SYMBOL_BID) <= op - (SniperSL_Pips * _Point * 10)) {
               trade.PositionClose(ticket);
               continue;
            }
         }
         else { 
            // Take Profit
            if(SymbolInfoDouble(_Symbol,SYMBOL_ASK) <= op - (SniperTP_Pips * _Point * 10)) {
               trade.PositionClose(ticket);
               continue;
            }
            // Stop Loss
            if(SniperSL_Pips > 0 && SymbolInfoDouble(_Symbol,SYMBOL_ASK) >= op + (SniperSL_Pips * _Point * 10)) {
               trade.PositionClose(ticket);
               continue;
            }
         }
      }
   }
}

int GetOpenSniperCount() {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && 
         PositionGetInteger(POSITION_MAGIC) == InpMagic && 
         PositionGetString(POSITION_COMMENT) == "Sniper") {
         count++;
      }
   }
   return count;
}

bool CheckAndExecuteSmartHedge() {
   int total = 0; for(int i=0; i<PositionsTotal(); i++) if(PositionSelectByTicket(PositionGetTicket(i)) && PositionGetInteger(POSITION_MAGIC)==InpMagic) total++;
   if(total == 0) {
      datetime curB = iTime(_Symbol, _Period, 0); if(curB == lastHedgeBar) return false;
      double atrB[], bbM[]; ArraySetAsSeries(atrB, true); ArraySetAsSeries(bbM, true);
      if(CopyBuffer(atrH, 0, 0, 1, atrB) > 0 && CopyBuffer(bbH, 0, 0, 1, bbM) > 0) {
         double cATR = atrB[0]/_Point/10.0, dist = MathAbs(SymbolInfoDouble(_Symbol, SYMBOL_BID)-bbM[0])/_Point/10.0;
         if(cATR >= MinATR_Pips && cATR <= MaxATR_Pips && dist <= MiddleDistPips) { OpenOrder(POSITION_TYPE_BUY, BaseLot); OpenOrder(POSITION_TYPE_SELL, BaseLot); lastHedgeBar = curB; return true; }
      }
   }
   return false;
}

void CloseSide(int m, ENUM_POSITION_TYPE t) { for(int i=PositionsTotal()-1; i>=0; i--) { ulong tk = PositionGetTicket(i); if(PositionSelectByTicket(tk) && PositionGetInteger(POSITION_MAGIC) == m && (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == t) trade.PositionClose(tk); } }
void UpdateFullAdaptiveLogic() { double atrB[]; ArraySetAsSeries(atrB, true); if(CopyBuffer(atrH, 0, 0, 1, atrB) > 0) { double cStep = (atrB[0]/_Point/10.0)*1.5; currentAdaptiveStep = MathMax(200.0, MathMin(500.0, cStep)); } }
void CheckRiskProtections() { 
   double bal=AccountInfoDouble(ACCOUNT_BALANCE), eq=AccountInfoDouble(ACCOUNT_EQUITY); 
   double dd=(bal>0)?(bal-eq)/bal*100:0; 
   if(EnableEquityProtection && dd>=MaxDrawdownPercent) { CloseAllNow("Equity Prot!"); g_limitReached=true; } 
   if(EnableProfitDaily && (bal-initialBalance)>=ProfitDaily) { g_limitReached=true; } 
}
void CloseAllNow(string r) { for(int i=PositionsTotal()-1; i>=0; i--) { ulong tk=PositionGetTicket(i); if(PositionSelectByTicket(tk)&&PositionGetInteger(POSITION_MAGIC)==InpMagic) trade.PositionClose(tk); } }

bool IsInLocalSession() { if(!EnableSessionFilter) return true; MqlDateTime dt; TimeLocal(dt); int cur = dt.hour * 60 + dt.min, start = StartHour * 60 + StartMinute, end = EndHour * 60 + EndMinute; if(start < end) return (cur >= start && cur < end); else return (cur >= start || cur < end); }
int GetICTMarketBias() { if(!EnableICTBias) return 0; double high[], low[]; ArraySetAsSeries(high, true); ArraySetAsSeries(low, true); if(CopyHigh(_Symbol,_Period,1,StructureLookback,high)<=0 || CopyLow(_Symbol,_Period,1,StructureLookback,low)<=0) return 0; double hMax = high[ArrayMaximum(high)], lMin = low[ArrayMinimum(low)]; if(iHigh(_Symbol,_Period,0) > hMax) return 1; if(iLow(_Symbol,_Period,0) < lMin) return -1; return 0; }
int GetHTFTrendBias() { if(!EnableHTFFilter) return 0; double ma[]; ArraySetAsSeries(ma, true); if(CopyBuffer(htfH, 0, 0, 1, ma) > 0) { double closePrice = iClose(_Symbol, HTF_Timeframe, 0); if(closePrice > ma[0]) return 1; if(closePrice < ma[0]) return -1; } return 0; }

int GetRSIDivergence() { 
   if(!EnableDivergence) return 0; 
   double rsi[]; 
   ArraySetAsSeries(rsi, true); 
   int copied = CopyBuffer(rsiH, 0, 0, RSIDivLookback, rsi);
   if(copied < 5) return 0; 
   if(iLow(_Symbol, _Period, 1) < iLow(_Symbol, _Period, 4) && rsi[1] > rsi[4]) { 
      g_divSignal = "BULLISH"; 
      return 1; 
   } 
   if(iHigh(_Symbol, _Period, 1) > iHigh(_Symbol, _Period, 4) && rsi[1] < rsi[4]) { 
      g_divSignal = "BEARISH"; 
      return -1; 
   } 
   g_divSignal = "NONE"; 
   return 0; 
}

//+------------------------------------------------------------------+
//| CHECK BOLLINGER BANDS WIDTH (HIGH WIN RATE FILTER) - FIXED FOR MQL5|
//+------------------------------------------------------------------+
bool IsBBWidthSafe() {
   double totalWidth = 0;
   int validCount = 0;
   
   // បង្កើត Array សម្រាប់ទាញយកទិន្នន័យពី Buffer របស់ iBands ក្នុង MQL5
   double upperB[], lowerB[];
   ArraySetAsSeries(upperB, true);
   ArraySetAsSeries(lowerB, true);
   
   // ទាញយកទិន្នន័យតាម Lookback period
   int copiedUpper = CopyBuffer(bbH, 1, 0, BBWidthLookback + 1, upperB);
   int copiedLower = CopyBuffer(bbH, 2, 0, BBWidthLookback + 1, lowerB);
   
   if(copiedUpper <= 0 || copiedLower <= 0) return true;
   
   for(int i=1; i<=BBWidthLookback; i++) {
      if(i < copiedUpper && i < copiedLower) {
         totalWidth += (upperB[i] - lowerB[i]);
         validCount++;
      }
   }
   
   if(validCount == 0) return true;
   double avgWidth = totalWidth / validCount;
   double currentWidth = upperB[0] - lowerB[0];
                        
   if(currentWidth > avgWidth * BBWidthMasterMultiplier) { 
   g_marketVolStatus = "HIGH VOL";
   return false; 
   }
   g_marketVolStatus = "SAFE";
   return true;
}

//+------------------------------------------------------------------+
//| CheckInitialGridEntry                                            |
//+------------------------------------------------------------------+
bool CheckInitialGridEntry(int div) { 
   if(!IsBBWidthSafe()) return false;

   double bbU[], bbL[], stoM[], rsiM[]; ArraySetAsSeries(bbU,true); ArraySetAsSeries(bbL,true); ArraySetAsSeries(stoM,true); ArraySetAsSeries(rsiM,true); 
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID), ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   
   if(CopyBuffer(bbH,1,0,1,bbU)>0 && CopyBuffer(bbH,2,0,1,bbL)>0 && CopyBuffer(stochH,0,0,1,stoM)>0 && CopyBuffer(rsiH,0,0,1,rsiM)>0) {
      if(bid <= bbL[0] && stoM[0] <= StochOverSold) {
         int score = 0; if(!EnableHTFFilter || g_marketBias >= 0) score++; if(!EnableICTBias || g_ictBias >= 0) score++; if(!EnableDivergence || div == 1 || rsiM[0] < 20) score++;
         if(score >= 2) { OpenOrder(POSITION_TYPE_BUY, BaseLot); return true; }
      }
      if(ask >= bbU[0] && stoM[0] >= StochOverBought) {
         int score = 0; if(!EnableHTFFilter || g_marketBias <= 0) score++; if(!EnableICTBias || g_ictBias <= 0) score++; if(!EnableDivergence || div == -1 || rsiM[0] > 80) score++;
         if(score >= 2) { OpenOrder(POSITION_TYPE_SELL, BaseLot); return true; }
      }
   } 
   return false; 
}

void CalculateTrendAndSignal() {
   double rsiVal[]; ArraySetAsSeries(rsiVal, true);
   double maVal[];  ArraySetAsSeries(maVal, true);
   if(CopyBuffer(rsiH, 0, 0, 1, rsiVal) <= 0 || CopyBuffer(htfH, 0, 0, 1, maVal) <= 0) return;
   double close0 = iClose(_Symbol, _Period, 0);
   double bScore = 0, sScore = 0;
   if(rsiVal[0] > 50) bScore += 30 * (rsiVal[0]/100); else sScore += 30 * ((100-rsiVal[0])/100);
   if(close0 > maVal[0]) bScore += 40; else sScore += 40;
   if(close0 > iOpen(_Symbol, _Period, 0)) bScore += 30; else sScore += 30;
   g_trendBuyStrength = bScore; g_trendSellStrength = sScore;
   if(bScore > 65) g_marketSignal = "BULLISH"; else if(sScore > 65) g_marketSignal = "BEARISH"; else g_marketSignal = "SIDEWAY";
}

bool ManageTrendZoneEntry() {
   double bbM[], bbU[], bbL[], atrB[]; ArraySetAsSeries(bbM, true); ArraySetAsSeries(bbU, true); ArraySetAsSeries(bbL, true); ArraySetAsSeries(atrB, true);
   if(CopyBuffer(bbH, 0, 0, 1, bbM) <= 0 || CopyBuffer(atrH, 0, 0, 1, atrB) <= 0) return false;
   CopyBuffer(bbH, 1, 0, 1, bbU); CopyBuffer(bbH, 2, 0, 1, bbL);
   bool m5B = (iClose(_Symbol, ScanTimeframe, 0) > iOpen(_Symbol, ScanTimeframe, 0)), m5S = (iClose(_Symbol, ScanTimeframe, 0) < iOpen(_Symbol, ScanTimeframe, 0));
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID), ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double hUp = bbM[0] + (MiddleDistPips * _Point * 10), hLo = bbM[0] - (MiddleDistPips * _Point * 10);
   bool isStrong = (MathAbs(iOpen(_Symbol,0,0) - iClose(_Symbol,0,0)) > atrB[0] * AtrMultiplier);
   bool hybridBuy = true, hybridSell = true;
   if(UseHybridFilter) { double rsiM[]; ArraySetAsSeries(rsiM, true); CopyBuffer(rsiH, 0, 0, 1, rsiM); hybridBuy = (rsiM[0] > 60); hybridSell = (rsiM[0] < 40); }
   datetime curB = iTime(_Symbol, _Period, 0);
   if(curB != lastTrendBarB && m5B && bid >= hUp && (g_marketBias >= 0) && isStrong && hybridBuy) { if(trade.Buy(TrendLotSize, _Symbol, ask, 0, 0, "TrendFollow")) { lastTrendBarB = curB; return true; } }
   if(curB != lastTrendBarS && m5S && bid <= hLo && (g_marketBias <= 0) && isStrong && hybridSell) { if(trade.Sell(TrendLotSize, _Symbol, bid, 0, 0, "TrendFollow")) { lastTrendBarS = curB; return true; } }
   return false;
}

bool ExecuteCandleSniper() {
   datetime currentBar = iTime(_Symbol, _Period, 0); if(currentBar == lastSniperBar) return false;
   if(GetOpenSniperCount() >= MaxSniperTrades) return false;
   double open1 = iOpen(_Symbol, _Period, 1), close1 = iClose(_Symbol, _Period, 1);
   double bodySize = MathAbs(close1 - open1) / _Point / 10.0;
   if(bodySize >= MinBodyPips) {
      if(close1 > open1 && (g_marketBias >= 0)) { if(trade.Buy(SniperLot, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), 0, 0, "Sniper")) { lastSniperBar = currentBar; return true; } }
      else if(close1 < open1 && (g_marketBias <= 0)) { if(trade.Sell(SniperLot, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID), 0, 0, "Sniper")) { lastSniperBar = currentBar; return true; } }
   }
   return false;
}

//+------------------------------------------------------------------+
//| DASHBOARD FUNCTIONS                                              |
//+------------------------------------------------------------------+
void CreatePremiumDashboard() {
   int bW = 530, bH = 630; int xL = 30; 
   CreateRect("DB_BG", 10, 10, bW, bH, C'15,15,15'); 
   CreateRect("DB_Side", 10, 10, 5, bH, clrYellow); 
   int y = 30;
   CreateHLine("DB_H_LineL", 100, y+8, 80, clrOrange);
   CreateLabel("DB_H_Title", 195, y-5, " 2Mruy-V1.2 ", 14, clrYellow); 
   CreateHLine("DB_H_LineR", 340, y+8, 80, clrOrange);
   y += 40; CreateLabel("DB_Sec1", xL, y, "Account", 11, clrAqua);
   y += 35;
   CreateLabel("DB_L_Stat", xL, y, "Status    : ", 9, clrWhite); CreateLabel("DB_V_Stat", xL+70, y, "Active", 9, clrLime);
   CreateLabel("DB_L_Mag", xL+170, y, "Magic ID : ", 9, clrWhite); CreateLabel("DB_V_Mag", xL+240, y, (string)InpMagic, 9, clrYellow);
   CreateLabel("DB_L_Acc", xL+310, y, "Account  : ", 9, clrWhite); CreateLabel("DB_V_Acc", xL+385, y, (string)AccountInfoInteger(ACCOUNT_LOGIN), 9, clrDeepSkyBlue);
   y += 35;
   CreateLabel("DB_L_Bal", xL, y, "Balance : ", 9, clrWhite); CreateLabel("DB_V_Bal", xL+70, y, "0.00", 9, clrSpringGreen);
   CreateLabel("DB_L_Eq", xL+170, y, "Equity : ", 9, clrWhite); CreateLabel("DB_V_Eq", xL+225, y, "0.00", 9, clrSpringGreen);
   CreateLabel("DB_L_Lic", xL+310, y, "License Expiry : ", 9, clrWhite); CreateLabel("DB_V_Lic", xL+420, y, g_licenseExpiry, 9, clrGold);
   y += 30; CreateHLine("DB_L1", xL, y+5, 490, clrChartreuse);
   y += 20; CreateLabel("DB_Sec2", xL, y, "Trading ⚡", 11, clrAqua);
   y += 35;
   CreateLabel("DB_L_Pos", xL, y, "Position  : ", 9, clrWhite); CreateLabel("DB_V_Pos", xL+75, y, "0", 9, clrLime);
   CreateLabel("DB_L_Buy", xL+170, y, "Buy  : ", 9, clrDeepSkyBlue); CreateLabel("DB_V_Buy", xL+220, y, "0", 9, clrDeepSkyBlue);
   CreateLabel("DB_L_Sel", xL+310, y, "Sell  : ", 9, clrOrange); CreateLabel("DB_V_Sel", xL+360, y, "0", 9, clrOrange);
   y += 35;
   CreateLabel("DB_L_Act", xL, y, "Action  : ", 9, clrWhite); CreateLabel("DB_V_Act", xL+60, y, "SCANNING", 9, clrGold);
   CreateLabel("DB_L_StrB", xL+170, y, "Buy  : ", 9, clrWhite); CreateLabel("DB_V_StrB", xL+220, y, "0%", 9, clrDeepSkyBlue);
   CreateLabel("DB_L_StrS", xL+310, y, "Sell  : ", 9, clrOrange); CreateLabel("DB_V_StrS", xL+360, y, "0%", 9, clrOrange);
   y += 30; CreateHLine("DB_L2", xL, y+5, 490, clrDodgerBlue);
   y += 20; CreateLabel("DB_Sec3", xL, y, "Market 🚀", 11, clrAqua);
   y += 35;
   CreateLabel("DB_L_ATR", xL, y, "ATR Val  : ", 9, clrWhite); CreateLabel("DB_V_ATR", xL+75, y, "0.0", 9, clrGold);
   CreateLabel("DB_L_Spread", xL+170, y, "Spread  : ", 9, clrWhite); CreateLabel("DB_V_Spread", xL+240, y, "0", 9, clrDeepSkyBlue);
   CreateLabel("DB_L_Signal", xL+310, y, "Signal  : ", 9, clrWhite); CreateLabel("DB_V_Signal", xL+375, y, "SIDEWAY", 9, clrLime);
   y += 35;
   CreateLabel("DB_L_Vol", xL, y, "Market    : ", 9, clrWhite); CreateLabel("DB_V_Vol", xL+75, y, "SAFE", 9, clrSpringGreen);
   CreateLabel("DB_L_RSI", xL+170, y, "RSI  : ", 9, clrWhite); CreateLabel("DB_V_RSI", xL+220, y, "Normal", 9, clrGold);
   CreateLabel("DB_L_News", xL+310, y, "News   : ", 9, clrMagenta); CreateLabel("DB_V_News", xL+375, y, "SAFE", 9, clrYellow);
   y += 30; CreateHLine("DB_L3", xL, y+5, 490, clrChartreuse);
   y += 20; CreateLabel("DB_Sec4", xL, y, "Risk Status 🔥", 11, clrAqua);
   y += 35;
   CreateLabel("DB_L_Stp", xL, y, "Step Pips  : ", 9, clrWhite); CreateLabel("DB_V_Stp", xL+85, y, "0.0", 9, clrDeepSkyBlue);
   CreateLabel("DB_L_RV", xL+170, y, "RSI Val  : ", 9, clrWhite); CreateLabel("DB_V_RV", xL+240, y, "0.0", 9, clrDeepSkyBlue);
   CreateLabel("DB_L_CI", xL+310, y, "Impact  : ", 9, clrWhite); CreateLabel("DB_V_CI", xL+380, y, "NONE", 9, clrRed);
   y += 35;
   CreateLabel("DB_L_DD", xL, y, "Max DD     : ", 9, clrWhite); CreateLabel("DB_V_DD", xL+85, y, "0.00%", 9, clrOrange);
   CreateLabel("DB_L_Prf", xL+170, y, "Net Prf   : ", 9, clrWhite); CreateLabel("DB_V_Prf", xL+240, y, "0.00", 9, clrWhite);
   y += 30; CreateHLine("DB_L4", xL, y+5, 490, clrDodgerBlue);
   y += 20; CreateLabel("DB_Sec5", xL, y, "Session ⏰", 11, clrAqua);
   y += 35;
   CreateLabel("DB_L_Time", xL, y, "Trading Time  : ", 9, clrPaleGoldenrod); 
   CreateLabel("DB_V_Time", xL+105, y, StringFormat("%02d:%02d - %02d:%02d", StartHour, StartMinute, EndHour, EndMinute), 9, clrDeepSkyBlue);
   CreateLabel("DB_L_Mkt", xL+310, y, "Server Status  : ", 9, clrPaleGoldenrod); CreateLabel("DB_V_Mkt", xL+420, y, "LIVE ●", 9, clrLime);
}

void UpdateDashboardValues() {
   double bal = AccountInfoDouble(ACCOUNT_BALANCE), eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double dd = (bal > 0) ? (bal - eq) / bal * 100.0 : 0; if(dd > maxDD_Session) maxDD_Session = dd;
   int bC = 0, sC = 0; for(int i=0; i<PositionsTotal(); i++) if(PositionSelectByTicket(PositionGetTicket(i)) && PositionGetInteger(POSITION_MAGIC)==InpMagic) { if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) bC++; else sC++; }
   double rsiB[]; ArraySetAsSeries(rsiB, true); CopyBuffer(rsiH, 0, 0, 1, rsiB);
   double atrB[]; ArraySetAsSeries(atrB, true); CopyBuffer(atrH, 0, 0, 1, atrB);
   ObjectSetString(0,"DB_V_Bal",OBJPROP_TEXT, DoubleToString(bal, 2)); ObjectSetString(0,"DB_V_Eq",OBJPROP_TEXT, DoubleToString(eq, 2));
   ObjectSetString(0,"DB_V_Pos",OBJPROP_TEXT, (string)(bC+sC)); ObjectSetString(0,"DB_V_Buy",OBJPROP_TEXT, (string)bC); ObjectSetString(0,"DB_V_Sel",OBJPROP_TEXT, (string)sC);
   if(g_limitReached) { ObjectSetString(0,"DB_V_Stat",OBJPROP_TEXT, "PAUSED"); ObjectSetInteger(0,"DB_V_Stat",OBJPROP_COLOR, clrYellow); ObjectSetString(0,"DB_V_Act",OBJPROP_TEXT, "Target Prf"); } 
   else { ObjectSetString(0,"DB_V_Stat",OBJPROP_TEXT, "Active"); ObjectSetInteger(0,"DB_V_Stat",OBJPROP_COLOR, clrLime); ObjectSetString(0,"DB_V_Act",OBJPROP_TEXT, g_currentAction); }
   ObjectSetString(0,"DB_V_StrB",OBJPROP_TEXT, DoubleToString(g_trendBuyStrength, 0) + "%"); ObjectSetString(0,"DB_V_StrS",OBJPROP_TEXT, DoubleToString(g_trendSellStrength, 0) + "%");
   ObjectSetString(0,"DB_V_ATR",OBJPROP_TEXT, (ArraySize(atrB)>0 ? DoubleToString(atrB[0]/_Point/10.0, 1) : "0.0"));
   ObjectSetString(0,"DB_V_Spread",OBJPROP_TEXT, (string)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD));
   ObjectSetString(0,"DB_V_Signal",OBJPROP_TEXT, g_marketSignal); ObjectSetString(0,"DB_V_News",OBJPROP_TEXT, g_newsStatus);
   ObjectSetInteger(0,"DB_V_News", OBJPROP_COLOR, (g_newsStatus == "SAFE" || g_newsStatus == "NO NEWS" ? clrYellow : clrOrange));
   ObjectSetString(0,"DB_V_CI",OBJPROP_TEXT, g_newsEvent); ObjectSetInteger(0,"DB_V_CI", OBJPROP_COLOR, (g_newsEvent == "NONE" ? clrYellow : clrRed));
   ObjectSetString(0,"DB_V_Vol",OBJPROP_TEXT, g_marketVolStatus); ObjectSetInteger(0,"DB_V_Vol", OBJPROP_COLOR, (g_marketVolStatus == "HIGH VOL" ? clrRed : clrSpringGreen));
   string rStatus = "Normal"; if(ArraySize(rsiB)>0) { if(rsiB[0]>80) rStatus="OB"; else if(rsiB[0]<20) rStatus="OS"; }
   ObjectSetString(0,"DB_V_RSI",OBJPROP_TEXT, rStatus); ObjectSetString(0,"DB_V_RV",OBJPROP_TEXT, (ArraySize(rsiB)>0 ? DoubleToString(rsiB[0], 1) : "0.0"));
   double dStp = (bC > 0 || sC > 0) ? (EnableDynamicStep ? GetDynamicStep(MathMax(bC,sC)) : currentAdaptiveStep) : currentAdaptiveStep;
   ObjectSetString(0,"DB_V_Stp",OBJPROP_TEXT, DoubleToString(dStp, 1)); ObjectSetString(0,"DB_V_DD",OBJPROP_TEXT, DoubleToString(maxDD_Session, 2) + "%");
   double prfUSD = bal - initialBalance; double prfPct = (initialBalance > 0) ? (prfUSD / initialBalance) * 100.0 : 0;
   string prfString = DoubleToString(prfUSD, 2) + " (" + DoubleToString(prfPct, 2) + "%)";
   ObjectSetString(0,"DB_V_Prf",OBJPROP_TEXT, prfString); ObjectSetInteger(0,"DB_V_Prf",OBJPROP_COLOR, (prfUSD >= 0 ? clrLime : clrRed));
}

void UpdateDashboardMotion() {
   color animCol = (g_animColorStep % 10 < 5) ? clrAqua : clrFuchsia;
   ObjectSetInteger(0,"DB_Sec1", OBJPROP_COLOR, animCol); ObjectSetInteger(0,"DB_Sec2", OBJPROP_COLOR, animCol);
   ObjectSetInteger(0,"DB_Sec3", OBJPROP_COLOR, animCol); ObjectSetInteger(0,"DB_Sec4", OBJPROP_COLOR, animCol);
   ObjectSetInteger(0,"DB_Sec5", OBJPROP_COLOR, animCol);
   ObjectSetString(0,"DB_V_Mkt",OBJPROP_TEXT, "LIVE " + (g_motionStep < 4 ? "●" : " "));
}

void CreateLabel(string n, int x, int y, string t, int sz, color col) { ObjectDelete(0, n); ObjectCreate(0,n,OBJ_LABEL,0,0,0); ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y); ObjectSetString(0,n,OBJPROP_TEXT,t); ObjectSetInteger(0,n,OBJPROP_COLOR,col); ObjectSetInteger(0,n,OBJPROP_FONTSIZE,sz); ObjectSetInteger(0,n,OBJPROP_ZORDER, 10); ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); }
void CreateRect(string n, int x, int y, int w, int h, color bg) { ObjectDelete(0, n); ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0); ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y); ObjectSetInteger(0,n,OBJPROP_XSIZE,w); ObjectSetInteger(0,n,OBJPROP_YSIZE,h); ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bg); ObjectSetInteger(0,n,OBJPROP_BORDER_TYPE,BORDER_FLAT); ObjectSetInteger(0,n,OBJPROP_COLOR,clrNONE); ObjectSetInteger(0,n,OBJPROP_ZORDER, 0); ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); }
void CreateHLine(string n, int x, int y, int w, color col) { ObjectDelete(0, n); if(ObjectCreate(0, n, OBJ_BUTTON, 0, 0, 0)) { ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x); ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y); ObjectSetInteger(0, n, OBJPROP_XSIZE, w); ObjectSetInteger(0, n, OBJPROP_YSIZE, 2); ObjectSetString(0, n, OBJPROP_TEXT, ""); ObjectSetInteger(0, n, OBJPROP_BGCOLOR, col); ObjectSetInteger(0, n, OBJPROP_COLOR, col); ObjectSetInteger(0, n, OBJPROP_BORDER_TYPE, BORDER_FLAT); ObjectSetInteger(0, n, OBJPROP_STATE, false); ObjectSetInteger(0, n, OBJPROP_ZORDER, 15); ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false); } }

//+------------------------------------------------------------------+
//| NEWS WEB REQUEST FUNCTION                                        |
//+------------------------------------------------------------------+
void FetchNewsFromWeb() { 
   if(!EnableNewsFilter) return; 
   string cookie=NULL, headers; char post[], result[]; string dateStr = TimeToString(TimeCurrent(), TIME_DATE); 
   string url = "https://ec.forexprostools.com/?importance=3&currencies=15&start_date="+dateStr+"&end_date="+dateStr; 
   int res = WebRequest("GET", url, cookie, NULL, 3000, post, 0, result, headers); 
   if(res == 200) { 
      string html = CharArrayToString(result); int pos = StringFind(html, "class=\"dateFont\"", 0); 
      if(pos > 0) { 
         int timePos = StringFind(html, "id=\"eventTime_", pos); 
         if(timePos > 0) { 
            int start = StringFind(html, ">", timePos) + 1; int end = StringFind(html, "<", start); 
            string timeStr = StringSubstr(html, start, end - start); g_nextNewsTime = StringToTime(dateStr + " " + timeStr); 
            int eventPos = StringFind(html, "class=\"left event\"", start);
            if(eventPos > 0) { int startE = StringFind(html, ">", eventPos) + 1; int endE = StringFind(html, "<", startE); string fullEvent = StringSubstr(html, startE, endE - startE); StringTrimLeft(fullEvent); StringTrimRight(fullEvent); if(StringFind(fullEvent, "CPI") >= 0) g_newsEvent = "CPI"; else if(StringFind(fullEvent, "Nonfarm") >= 0) g_newsEvent = "NFP"; else if(StringFind(fullEvent, "FOMC") >= 0) g_newsEvent = "FOMC"; else if(StringFind(fullEvent, "Fed") >= 0) g_newsEvent = "FED RATE"; else if(StringFind(fullEvent, "GDP") >= 0) g_newsEvent = "GDP"; else if(StringLen(fullEvent) > 12) g_newsEvent = StringSubstr(fullEvent, 0, 10) + ".."; else g_newsEvent = fullEvent; } 
            else { g_newsEvent = "USD HIGH"; }
         } 
      } 
   } else { g_newsStatus = "SYNC ERR"; } 
}

bool IsNewsTime() {
   if(!EnableNewsFilter) return false; static datetime lastNF = 0; if(TimeCurrent() - lastNF > 1800) { FetchNewsFromWeb(); lastNF = TimeCurrent(); } 
   if(g_nextNewsTime > 0) { 
      long diff = (long)g_nextNewsTime - (long)TimeCurrent(); 
      if(diff > 0) { int h = (int)(diff / 3600); int m = (int)((diff % 3600) / 60); int s = (int)(diff % 60); g_newsCountdown = StringFormat("%02d:%02d:%02d", h, m, s); g_newsStatus = g_newsCountdown; } 
      else if (diff <= 0 && diff > -StopAfterNews * 60) { g_newsStatus = "LIVE"; g_newsCountdown = "LIVE"; } 
      else { g_newsStatus = "SAFE"; g_newsEvent = "NONE"; g_newsCountdown = "00:00:00"; }
      if(diff <= StopBeforeNews * 60 && diff > -StopAfterNews * 60) return true; 
   } else { g_newsStatus = "NO NEWS"; g_newsEvent = "NONE"; g_newsCountdown = "00:00:00"; }
   return false; 
}

//+------------------------------------------------------------------+
//| Online License Verification Function                             |
//+------------------------------------------------------------------+
bool VerifyLicenseOnline()
{
    // Bypasses license check if running in Strategy Tester (since WebRequest is disabled in tester)
    if(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION))
    {
        Print("ℹ️ Strategy Tester detected. Online license check bypassed for backtesting.");
        g_licenseExpiry = "BACKTEST MODE";
        return true;
    }

    long currentAccountNumber = AccountInfoInteger(ACCOUNT_LOGIN);
    string url = StringFormat("%s?key=%s&account=%d", LicenseServerUrl, LicenseKey, currentAccountNumber);
    
    string cookie = NULL, headers;
    char post[], result[];
    
    int res = WebRequest("GET", url, cookie, NULL, 3000, post, 0, result, headers);
    
    if(res == 200)
    {
        string responseStr = CharArrayToString(result);
        if(StringFind(responseStr, "\"status\":\"active\"") >= 0)
        {
            Print("✅ LICENSE SUCCESS: License Key is active and verified.");
            string expiry = ParseJSONString(responseStr, "expiry");
            if(expiry != "") g_licenseExpiry = expiry;
            else g_licenseExpiry = "Active";
            return true;
        }
        else
        {
            Print("❌ LICENSE FAILED: Server returned: ", responseStr);
            g_licenseExpiry = "REVOKED / INVALID";
        }
    }
    else
    {
        Print("❌ LICENSE SERVER ERROR: Connection failed! Code: ", res);
        g_licenseExpiry = "SERVER ERROR (" + (string)res + ")";
    }
    return false;
}

//+------------------------------------------------------------------+
//| Parse a string value from a simple JSON string                   |
//+------------------------------------------------------------------+
string ParseJSONString(string json, string key)
{
   string searchPattern = "\"" + key + "\":\"";
   int pos = StringFind(json, searchPattern);
   if(pos < 0) return "";
   int start = pos + StringLen(searchPattern);
   int end = StringFind(json, "\"", start);
   if(end < 0) return "";
   return StringSubstr(json, start, end - start);
}

