mock "tfconfig" {
  module {
    source = "./policies/mocks/mock-tfconfig.sentinel"
  }
}

mock "tfconfig/v1" {
  module {
    source = "./policies/mocks/mock-tfconfig.sentinel"
  }
}

mock "tfconfig/v2" {
  module {
    source = "./policies/mock/mock-tfconfig-v2.sentinel"
  }
}

mock "tfplan" {
  module {
    source = "./policies/mockmock-tfplan.sentinel"
  }
}

mock "tfplan/v1" {
  module {
    source = "./policies/mock/mock-tfplan.sentinel"
  }
}

mock "tfplan/v2" {
  module {
    source = "./policies/mock/mock-tfplan-v2.sentinel"
  }
}

mock "tfstate" {
  module {
    source = "./policies/mock/mock-tfstate.sentinel"
  }
}

mock "tfstate/v1" {
  module {
    source = "./policies/mock/mock-tfstate.sentinel"
  }
}

mock "tfstate/v2" {
  module {
    source = "./policies/mock/mock-tfstate-v2.sentinel"
  }
}

mock "tfrun" {
  module {
    source = "./policies/mock/mock-tfrun.sentinel"
  }
}
