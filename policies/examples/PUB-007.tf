# Пример для правила PUB-007: ресурсы bad_* нарушают правило, good_* — нет.

resource "azurerm_network_security_rule" "bad_rdp_any" {
  name                       = "rdp"
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = "*"
  destination_port_range     = "3389"
}

resource "azurerm_network_security_group" "bad_nsg_ssh_internet" {
  name = "nsg"
  security_rule {
    name                   = "ssh"
    direction              = "Inbound"
    access                 = "Allow"
    source_address_prefix  = "Internet"
    destination_port_range = "20-30"
  }
}

resource "azurerm_network_security_rule" "good_https_any" {
  name                   = "https"
  direction              = "Inbound"
  access                 = "Allow"
  source_address_prefix  = "*"
  destination_port_range = "443"
}
