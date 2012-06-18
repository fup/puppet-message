define message::publish (
  $topic,
  $expiration => $messaage::params::default_expiration
) inherits messages::params {
  publish($topic, $name, $expiration)
}
