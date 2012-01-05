class Ability
  include CanCan::Ability

  def initialize(account)
    if account
      if account.admin?
        can :manage, :all
      else
        if account.reader? || account.controller? || account.treasurer || account.license_official?
          can :read, [Flight, TowFlight, :dashboards, :filtered_flights, :own_financial_account]
        end
        if account.controller?
          can [:read, :create], [Person, Plane, Airfield, WireLauncher, Flight, TowFlight]
          can :update, [Flight, TowFlight]
        end
        if account.treasurer?
          can :manage, [  Person, Plane, Airfield, Flight, TowFlight, Group,
                          PersonCostCategory, PlaneCostCategory, WireLauncherCostCategory,
                          FinancialAccount, :cost_rules, CostHint,
                          FlightCostRule, WireLaunchCostRule, 
                          CostRuleCondition, FlightCostItem, WireLaunchCostItem,
                          PersonCostCategoryMembership, PlaneCostCategoryMembership,
                          WireLauncherCostCategoryMembership ]
        end
        if account.license_official?
          can :manage, [Person, License, LegalPlaneClass]
        end
      end
    end
  end
end
