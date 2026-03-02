enum AccountType { cash, bank, creditCard, eWallet, investment, other }

enum AssetTerm {
  current, // < 1 year
  shortTerm, // 1-3 years
  longTerm, // > 3 years
}

enum TransactionType { expense, income, transfer }

enum CategoryType { expense, income }

enum BudgetPeriod { weekly, monthly, yearly }

enum RecurringFrequency { daily, weekly, monthly, yearly }

enum ReceivablePayableType { receivable, payable }

enum ReceivablePayableStatus { pending, partiallyPaid, paid, overdue }
