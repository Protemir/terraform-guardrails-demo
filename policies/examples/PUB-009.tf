# Пример для правила PUB-009: ресурсы bad_* нарушают правило, good_* — нет.

resource "google_compute_firewall" "bad_ssh_world" {
  name          = "allow-ssh"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "good_https_world" {
  name          = "allow-https"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}
