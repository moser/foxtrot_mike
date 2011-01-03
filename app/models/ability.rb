class Ability  
  include CanCan::Ability

  def self.roles
    [ :admin, :license_official, :treasurer, :controller, :reader ]
  end  
  
  def initialize(account)
    if account
      if account.role? :admin
        can :manage, :all
      else
        if account.role?(:reader) || account.role?(:controller) || account.role?(:treasurer) || account.role?(:license_official) 
          can :read, [Flight, :dashboards, :filtered_flights]
        end
        if account.role?(:controller)
          can [:read, :create], [Person, Plane, Airfield, Flight]
          can :update, Flight
        end
        if account.role?(:treasurer)
          can :manage, [Person, Plane, Airfield, Flight, Group, 
                        PersonCostCategory, PlaneCostCategory, WireLauncherCostCategory,
                        FinancialAccount, :cost_rules, TimeCostRule, WireLaunchCostRule,
                        PersonCostCategoryMembership, PlaneCostCategoryMembership,
                        WireLauncherCostCategoryMembership, CostHint]       
        end
        if account.role?(:license_official)
          can :manage, [Person, License, LegalPlaneClass]
        end
      end
    end
  end  
end 
